import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nox/core/ens/ens_repository.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/send/presentation/widgets/_form_atoms.dart';
import 'package:nox/features/send/presentation/widgets/contact_picker_dialog.dart';

part 'contact_picker_panel.dart';

// ---------------------------------------------------------------------------
// Address field — single unified border reacts to focus / error
// ---------------------------------------------------------------------------

class AddressField extends StatefulWidget {
  const AddressField({
    required this.controller,
    required this.locked,
    required this.errorText,
    required this.contacts,
    required this.onChanged,
    required this.onContactSelected,
    super.key,
  });

  final TextEditingController controller;
  final bool locked;
  final String? errorText;
  final List<Contact> contacts;
  final ValueChanged<String> onChanged;
  final ValueChanged<Contact> onContactSelected;

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  final FocusNode _focus = FocusNode();
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchCtrl = TextEditingController();
  final _pickerLink = LayerLink();
  final _ensRepo = const EnsGrpcRepository();
  OverlayEntry? _entry;
  bool _focused = false;
  bool _showContacts = false;
  String _query = '';

  // ENS state — debounced resolve while the user types `name.eth`.
  Timer? _ensDebounce;
  String _ensName = ''; // last resolved name displayed to the user
  String _ensResolvedAddress = ''; // hex address backing the displayed name
  bool _ensResolving = false;
  bool _ensFailed = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
    // Rebuild on every controller change so the green-checkmark validity
    // indicator reflects the current text. The notifier already listens to
    // controller changes for state propagation; we only need a UI tick here.
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _maybeResolveENS(widget.controller.text);
  }

  // Triggered on every text change. If the value looks like an ENS name,
  // debounce 350 ms and resolve. The resolved address is **not** auto-
  // substituted into the controller — the user should still see the name
  // they typed. We pass the resolved address up via `widget.onChanged` so
  // the form-level notifier can validate / send to the right address.
  void _maybeResolveENS(String raw) {
    _ensDebounce?.cancel();
    final t = raw.trim().toLowerCase();
    if (!t.endsWith('.eth') || t.length < 5) {
      // Not an ENS lookup — clear any prior resolution state.
      if (_ensName.isNotEmpty || _ensResolving || _ensFailed) {
        setState(() {
          _ensName = '';
          _ensResolvedAddress = '';
          _ensResolving = false;
          _ensFailed = false;
        });
      }
      return;
    }

    setState(() {
      _ensResolving = true;
      _ensFailed = false;
    });

    _ensDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final addr = await _ensRepo.resolve(t);
        if (!mounted) return;
        setState(() {
          _ensResolving = false;
          if (addr.isEmpty) {
            _ensName = '';
            _ensResolvedAddress = '';
            _ensFailed = true;
          } else {
            _ensName = t;
            _ensResolvedAddress = addr;
            _ensFailed = false;
          }
        });
        // Hand the resolved address to the form so validation passes.
        if (addr.isNotEmpty) widget.onChanged(addr);
      } on Object {
        if (!mounted) return;
        setState(() {
          _ensResolving = false;
          _ensFailed = true;
          _ensName = '';
          _ensResolvedAddress = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _entry?.remove();
    _ensDebounce?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    _focus.dispose();
    _searchFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleContacts() {
    if (_showContacts) {
      _closeContacts();
    } else {
      _openContacts();
    }
  }

  void _closeContacts() {
    _entry?.remove();
    _entry = null;
    _query = '';
    _searchCtrl.clear();
    _searchFocus.unfocus();
    if (mounted) setState(() => _showContacts = false);
  }

  void _openContacts() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeContacts,
            ),
          ),
          CompositedTransformFollower(
            link: _pickerLink,
            showWhenUnlinked: false,
            offset: Offset(0, box.size.height + 6),
            child: _ContactPickerPanel(
              width: width,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              query: _query,
              onQueryChanged: (v) {
                setState(() => _query = v.trim());
                _entry?.markNeedsBuild();
              },
              contacts: widget.contacts,
              onContactPicked: _pickContact,
              onClose: _closeContacts,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() => _showContacts = true);
    // Focus search field once the overlay has been mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showContacts) _searchFocus.requestFocus();
    });
  }

  void _pickContact(Contact c) {
    widget.onContactSelected(c);
    _closeContacts();
  }

  /// True when the controller's current text looks like a valid 0x… address.
  /// Lightweight heuristic — server-side validation is still authoritative.
  bool get _addressLooksValid {
    final t = widget.controller.text.trim();
    if (t.length != 42) return false;
    if (!t.startsWith('0x') && !t.startsWith('0X')) return false;
    return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(t);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final isValid = !hasError && _addressLooksValid;
    final borderColor = _showContacts
        ? context.colors.primary.withValues(alpha: 0.55)
        : hasError
        ? context.colors.error
        : isValid
        ? context.colors.success.withValues(alpha: 0.55)
        : _focused
        ? context.colors.primary
        : context.colors.border;
    final iconColor = hasError && !_showContacts
        ? context.colors.error.withValues(alpha: 0.7)
        : (_focused || _showContacts)
        ? context.colors.primary.withValues(alpha: 0.7)
        : context.colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Main container (anchor for the contact-picker overlay) ──────────
        CompositedTransformTarget(
          link: _pickerLink,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: (_focused || hasError || _showContacts)
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.12),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Tag — uppercase label inside the card matches the
                  // visual language of Asset / Amount / Pay / Receive cards.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TO',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: context.colors.textDisabled,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // ── Address input row ───────────────────────────────────────
                  ColoredBox(
                    color: context.colors.surfaceHigh,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: iconColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: context.colors.border,
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focus,
                            enabled: !widget.locked,
                            style: AppTextStyles.mono.copyWith(
                              color: context.colors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: '0x... or ENS name',
                              hintStyle: AppTextStyles.mono.copyWith(
                                color: context.colors.textDisabled,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            onChanged: widget.onChanged,
                          ),
                        ),
                        // Inline validation indicator — appears once the
                        // address is well-formed. Server-side validation in
                        // SendNotifier is still authoritative; this is just a
                        // visual confirmation that the user typed all 42 chars.
                        if (isValid)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: context.colors.success,
                            ),
                          ),
                        if (widget.contacts.isNotEmpty)
                          IconBtn(
                            icon: _showContacts
                                ? Icons.person_search_rounded
                                : Icons.person_search_outlined,
                            tooltip: _showContacts ? 'Close contacts' : 'Choose from contacts',
                            color: _showContacts ? context.colors.primary : null,
                            onTap: widget.locked ? null : _toggleContacts,
                          ),
                        IconBtn(
                          icon: Icons.content_paste_rounded,
                          tooltip: 'Paste',
                          onTap: widget.locked
                              ? null
                              : () async {
                                  final data = await Clipboard.getData(
                                    Clipboard.kTextPlain,
                                  );
                                  final text = data?.text ?? '';
                                  widget.controller.text = text;
                                  widget.onChanged(text);
                                },
                        ),
                        const SizedBox(width: 6),
                      ],
                    ), // Row
                  ), // ColoredBox (address row)
                ],
              ),
            ),
          ),
        ),

        // ── Inline validation error ─────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: context.colors.error,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.errorText!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.error,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── ENS resolution status ───────────────────────────────────────────
        // Shown only while the user is typing a `*.eth` name. Three states:
        //   - resolving: spinner + "Resolving …"
        //   - resolved : green check + "vitalik.eth → 0xd8dA…6045"
        //   - failed   : amber warning + "ENS name not found"
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: _buildEnsStatus(context),
        ),
      ],
    );
  }

  Widget _buildEnsStatus(BuildContext context) {
    if (_ensResolving) {
      return Padding(
        padding: const EdgeInsets.only(top: 5, left: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Resolving ENS…',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    if (_ensResolvedAddress.isNotEmpty) {
      final addr = _ensResolvedAddress;
      final short = '${addr.substring(0, 8)}…${addr.substring(addr.length - 6)}';
      return Padding(
        padding: const EdgeInsets.only(top: 5, left: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 12,
              color: context.colors.success,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$_ensName → $short',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.success,
                  fontSize: 11,
                  fontFamily: AppTextStyles.mono.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    if (_ensFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: 5, left: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 12,
              color: context.colors.warning,
            ),
            const SizedBox(width: 4),
            Text(
              'ENS name not found',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.warning,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// _ContactPickerPanel lives in the part file contact_picker_panel.dart.
