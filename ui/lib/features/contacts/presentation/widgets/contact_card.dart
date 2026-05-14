import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/row_icon_button.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';

part 'contact_edit_content.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contact card
// ─────────────────────────────────────────────────────────────────────────────

class ContactCard extends ConsumerStatefulWidget {
  const ContactCard({required this.contact, super.key});
  final Contact contact;

  @override
  ConsumerState<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends ConsumerState<ContactCard> {
  bool _hovered = false;
  bool _editing = false;
  bool _saving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _noteCtrl;

  Contact get c => widget.contact;

  String get _shortAddr {
    if (c.address.length <= 18) return c.address;
    return '${c.address.substring(0, 10)}…${c.address.substring(c.address.length - 6)}';
  }

  String get _letter => c.name.trim().isNotEmpty ? c.name.trim()[0].toUpperCase() : '?';

  Color get _avatarColor {
    const palette = [
      Color(0xFF6366F1),
      Color(0xFF00B894),
      Color(0xFF0984E3),
      Color(0xFFE17055),
      Color(0xFFD63031),
      Color(0xFF6AB04C),
      Color(0xFFE84393),
      Color(0xFF00CEC9),
    ];
    return palette[_letter.codeUnitAt(0) % palette.length];
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: c.name);
    _addrCtrl = TextEditingController(text: c.address);
    _noteCtrl = TextEditingController(text: c.note);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    _nameCtrl.text = c.name;
    _addrCtrl.text = c.address;
    _noteCtrl.text = c.note;
    setState(() => _editing = true);
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _saveEdit() async {
    final name = _nameCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    if (name.isEmpty || addr.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(contactsNotifierProvider.notifier)
          .edit(c.id, name, addr, _noteCtrl.text.trim());
      if (mounted) {
        setState(() {
          _editing = false;
          _saving = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        AppSnackBar.error(context, errorMessage(e));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await ref.read(contactsNotifierProvider.notifier).toggleFavorite(c.id);
    } on Object catch (e) {
      if (mounted) AppSnackBar.error(context, errorMessage(e));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'Delete contact?',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
        content: Text(
          'Remove "${c.name}" from your contacts? This cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: context.colors.textSecondary),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(contactsNotifierProvider.notifier).delete(c.id);
        if (mounted) AppSnackBar.success(context, 'Contact deleted.');
      } on Object catch (e) {
        if (mounted) AppSnackBar.error(context, errorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(contactsSearchProvider).toLowerCase().trim();
    final col = _avatarColor;
    final border = _editing
        ? context.colors.primary.withValues(alpha: 0.45)
        : (_hovered ? context.colors.primary.withValues(alpha: 0.22) : context.colors.border);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: (_hovered || _editing) ? context.colors.surfaceHigh : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: _editing ? 1.5 : 1.0),
          boxShadow: (_hovered || _editing)
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Favorite star (before avatar, same as token tile pin) ─────
            AnimatedOpacity(
              opacity: (_hovered || c.isFavorite) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Tooltip(
                message: c.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      c.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: c.isFavorite ? const Color(0xFFF59E0B) : context.colors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),

            // ── Avatar ────────────────────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: col.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                _letter,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: col),
              ),
            ),

            const SizedBox(width: 12),

            // ── Content (normal ↔ edit) ───────────────────────────────────
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeOut,
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeOut,
                crossFadeState: _editing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: _NormalContent(
                  name: c.name,
                  shortAddr: _shortAddr,
                  note: c.note,
                  query: query,
                  onSend: () {
                    ref.read(sendNotifierProvider.notifier).setToAddress(c.address);
                    context.go(Routes.send);
                  },
                  onCopy: () {
                    unawaited(Clipboard.setData(ClipboardData(text: c.address)));
                    AppSnackBar.info(context, 'Address copied.');
                  },
                  onEdit: _startEdit,
                  onDelete: _delete,
                ),
                secondChild: _EditContent(
                  nameCtrl: _nameCtrl,
                  addrCtrl: _addrCtrl,
                  noteCtrl: _noteCtrl,
                  saving: _saving,
                  onSave: _saveEdit,
                  onCancel: _cancelEdit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Normal view content
// ─────────────────────────────────────────────────────────────────────────────

class _NormalContent extends StatelessWidget {
  const _NormalContent({
    required this.name,
    required this.shortAddr,
    required this.note,
    required this.query,
    required this.onSend,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final String shortAddr;
  final String note;
  final String query;
  final VoidCallback onSend;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nameTxt = AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary);
    final addrTxt = AppTextStyles.monoSmall.copyWith(color: context.colors.textSecondary);
    final noteTxt = AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Name + address + note ──────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HighlightText(text: name, query: query, style: nameTxt),
              const SizedBox(height: 3),
              _HighlightText(text: shortAddr, query: query, style: addrTxt),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(note, style: noteTxt, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ── Action buttons ─────────────────────────────────────────────────
        // Shared RowIconButton — neutral at rest, primary tint on hover.
        // Only Delete keeps a red accent (danger: true) because it's
        // destructive. Previously Send was bright primary and Copy/Edit
        // were dim grey custom widgets — inconsistent visual weight for
        // actions of similar tier.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RowIconButton(icon: Icons.send_rounded, tooltip: 'Send', onTap: onSend),
            const SizedBox(width: 4),
            RowIconButton(icon: Icons.copy_rounded, tooltip: 'Copy address', onTap: onCopy),
            const SizedBox(width: 4),
            RowIconButton(icon: Icons.edit_rounded, tooltip: 'Edit', onTap: onEdit),
            const SizedBox(width: 4),
            RowIconButton(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete',
              danger: true,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

// _EditContent lives in the part file contact_edit_content.dart.

// ─────────────────────────────────────────────────────────────────────────────
// Highlight text (highlights query match in amber/primary)
// ─────────────────────────────────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  const _HighlightText({required this.text, required this.query, required this.style});

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }
    const hlColor = Color(0xFF6366F1);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
              color: hlColor,
              backgroundColor: Color(0x286366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (idx + query.length < text.length) TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// SkeletonCard moved to contact_skeleton.dart.
