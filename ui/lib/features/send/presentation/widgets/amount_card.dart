import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';
import 'package:nox/features/send/presentation/widgets/send_asset_list_panel.dart';

// ---------------------------------------------------------------------------
// Amount card shell (shared decoration for skeleton / error states)
// ---------------------------------------------------------------------------

class AmountCardShell extends StatelessWidget {
  const AmountCardShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colors.border),
    ),
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Amount card — unified layout that mirrors SwapPayCard.
//
// Earlier the Send form had two separate cards (Asset + Amount). This was
// inconsistent with the Swap pay card, which keeps the input on the left and
// the token pill on the right inside one card. Merging them halves the
// vertical footprint and gives both forms the same visual language.
//
//   ┌──────────────────────────────────────────────┐
//   │ AMOUNT                          [⊘ ETH ▾]    │
//   │ 0.00                                          │
//   │ ────────────────────────────────────────────  │
//   │ ⓦ 0.0085 ETH        25%  50%  75%  MAX       │
//   └──────────────────────────────────────────────┘
// ---------------------------------------------------------------------------

class AmountCard extends StatefulWidget {
  const AmountCard({
    required this.controller,
    required this.locked,
    required this.assets,
    required this.selectedAsset,
    required this.hasError,
    required this.onAssetChanged,
    required this.onAmountChanged,
    required this.onMaxPressed,
    required this.onFraction,
    super.key,
  });

  final TextEditingController controller;
  final bool locked;
  final List<SendAsset> assets;
  final SendAsset? selectedAsset;
  final bool hasError;
  final ValueChanged<SendAsset> onAssetChanged;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback? onMaxPressed;
  final ValueChanged<double>? onFraction;

  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> {
  final FocusNode _focus = FocusNode();
  final _selectorLink = LayerLink();
  OverlayEntry? _entry;
  bool _focused = false;
  bool _selectorOpen = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _entry?.remove();
    _focus.dispose();
    super.dispose();
  }

  bool get _canOpenSelector => !widget.locked && widget.assets.length > 1;

  void _toggleSelector() {
    if (!_canOpenSelector) return;
    if (_selectorOpen) {
      _closeSelector();
    } else {
      _showSelector();
    }
  }

  void _closeSelector() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _selectorOpen = false);
  }

  void _showSelector() {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _closeSelector),
          ),
          CompositedTransformFollower(
            link: _selectorLink,
            showWhenUnlinked: false,
            // Anchor below the token pill, right-aligned to it.
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: SendAssetListPanel(
              assets: widget.assets,
              selected: widget.selectedAsset,
              onPicked: (a) {
                widget.onAssetChanged(a);
                _closeSelector();
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() => _selectorOpen = true);
  }

  static String _fmtBalance(SendAsset a) {
    final bal = double.tryParse(a.balance) ?? 0;
    final s = bal.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$s ${a.symbol}';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? context.colors.error.withValues(alpha: 0.6)
        : _focused
        ? context.colors.primary
        : _selectorOpen
        ? context.colors.primary.withValues(alpha: 0.55)
        : context.colors.border;

    final s = widget.selectedAsset;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: (_focused || widget.hasError || _selectorOpen)
            ? [BoxShadow(color: borderColor.withValues(alpha: 0.12), blurRadius: 6)]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Tag ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
              child: Text(
                'AMOUNT',
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colors.textDisabled,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Number input (left) + token pill (right) ───────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: !widget.locked,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.mono.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTextStyles.mono.copyWith(
                        color: context.colors.textDisabled,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
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
                      contentPadding: const EdgeInsets.fromLTRB(16, 6, 10, 8),
                    ),
                    onChanged: widget.onAmountChanged,
                  ),
                ),

                Container(width: 1, height: 38, color: context.colors.border),

                // ── Token pill ───────────────────────────────────────
                CompositedTransformTarget(
                  link: _selectorLink,
                  child: MouseRegion(
                    cursor: _canOpenSelector ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: _toggleSelector,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s != null) ...[
                              TokenIcon(symbol: s.symbol, logoUrl: s.logoUrl, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                s.symbol,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ] else
                              Text(
                                'Select',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            if (_canOpenSelector) ...[
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: _selectorOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: _selectorOpen
                                      ? context.colors.primary
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Divider(height: 1, color: context.colors.border),

            // ── Balance + % buttons ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: Row(
                children: [
                  if (s != null) ...[
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 12,
                      color: context.colors.textDisabled,
                    ),
                    const SizedBox(width: 5),
                    MaskableText(
                      _fmtBalance(s),
                      style: AppTextStyles.monoSmall.copyWith(color: context.colors.textDisabled),
                    ),
                  ],
                  const Spacer(),
                  for (final pct in [0.25, 0.5, 0.75]) ...[
                    const SizedBox(width: 5),
                    _PctButton(
                      label: '${(pct * 100).toInt()}%',
                      onTap: widget.onFraction != null ? () => widget.onFraction!(pct) : null,
                    ),
                  ],
                  const SizedBox(width: 5),
                  _PctButton(label: 'MAX', isMax: true, onTap: widget.onMaxPressed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Percentage quick-set buttons
// ---------------------------------------------------------------------------

class _PctButton extends StatefulWidget {
  const _PctButton({required this.label, required this.onTap, this.isMax = false});
  final String label;
  final VoidCallback? onTap;
  final bool isMax;

  @override
  State<_PctButton> createState() => _PctButtonState();
}

class _PctButtonState extends State<_PctButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isMax
                ? (_hovered && widget.onTap != null
                      ? context.colors.primary.withValues(alpha: 0.22)
                      : context.colors.primary.withValues(alpha: 0.12))
                : (_hovered && widget.onTap != null
                      ? context.colors.primary.withValues(alpha: 0.08)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isMax
                  ? context.colors.primary.withValues(alpha: 0.4)
                  : context.colors.border,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.onTap == null
                  ? context.colors.textDisabled
                  : widget.isMax
                  ? context.colors.primary
                  : context.colors.textSecondary,
              fontSize: 11,
              fontWeight: widget.isMax ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: widget.isMax ? 0.4 : 0,
            ),
          ),
        ),
      ),
    );
  }
}
