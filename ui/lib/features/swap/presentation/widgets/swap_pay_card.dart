import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/widgets/_swap_atoms.dart';
import 'package:nox/features/swap/presentation/widgets/swap_asset_list_panel.dart';

// ---------------------------------------------------------------------------
// "You pay" card — token selector + amount input + % buttons + balance
// ---------------------------------------------------------------------------

class SwapPayCard extends StatefulWidget {
  const SwapPayCard({
    required this.assets,
    required this.selected,
    required this.controller,
    required this.locked,
    required this.exceedsBalance,
    required this.onAssetChanged,
    required this.onAmountChanged,
    required this.onFraction,
    required this.onMaxPressed,
    super.key,
  });

  final List<SwapAsset> assets;
  final SwapAsset? selected;
  final TextEditingController controller;
  final bool locked;
  final bool exceedsBalance;
  final ValueChanged<SwapAsset> onAssetChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<double>? onFraction;
  final VoidCallback? onMaxPressed;

  @override
  State<SwapPayCard> createState() => _SwapPayCardState();
}

class _SwapPayCardState extends State<SwapPayCard> {
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

  bool get _canOpen => !widget.locked && widget.assets.length > 1;

  void _toggleSelector() {
    if (!_canOpen) return;
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeSelector,
            ),
          ),
          CompositedTransformFollower(
            link: _selectorLink,
            showWhenUnlinked: false,
            // Anchor the panel below the token pill, right-aligned to it.
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: SwapAssetListPanel(
              assets: widget.assets,
              selected: widget.selected,
              onPicked: _selectAsset,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() => _selectorOpen = true);
  }

  void _selectAsset(SwapAsset a) {
    widget.onAssetChanged(a);
    _closeSelector();
  }

  static String _fmtBalance(SwapAsset a) {
    final raw = a.balance.replaceAll(RegExp(r'[^\d.]'), '');
    final val = double.tryParse(raw) ?? 0;
    final s = val.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$s ${a.symbol}';
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.exceedsBalance;
    final borderColor = hasError
        ? context.colors.error
        : _focused
        ? context.colors.primary
        : _selectorOpen
        ? context.colors.primary.withValues(alpha: 0.55)
        : context.colors.border;

    final s = widget.selected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: hasError ? context.colors.error.withValues(alpha: 0.04) : context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: (hasError || _focused || _selectorOpen)
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.14),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Tag — replaces the old "You pay" section label above the
            // card so we save the vertical it used to occupy. ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
              child: Text(
                'PAY',
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colors.textDisabled,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // ── Amount input (left) + token selector (right) ───────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Amount input — left, full width
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: !widget.locked,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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

                // Vertical divider
                Container(width: 1, height: 38, color: context.colors.border),

                // Token selector — compact, right side
                CompositedTransformTarget(
                  link: _selectorLink,
                  child: MouseRegion(
                    cursor: _canOpen ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: _toggleSelector,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s != null) ...[
                              TokenIcon(
                                symbol: s.symbol,
                                address: s.tokenAddress,
                                size: 22,
                              ),
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
                            if (_canOpen) ...[
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

            // ── Divider ─────────────────────────────────────────────────
            Divider(
              height: 1,
              color: hasError
                  ? context.colors.error.withValues(alpha: 0.25)
                  : context.colors.border,
            ),

            // ── % buttons + balance (or error) ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: Row(
                children: [
                  // Balance / error indicator
                  if (hasError) ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: context.colors.error,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Insufficient balance',
                      style: AppTextStyles.monoSmall.copyWith(
                        color: context.colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else if (s != null) ...[
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 12,
                      color: context.colors.textDisabled,
                    ),
                    const SizedBox(width: 5),
                    MaskableText(
                      _fmtBalance(s),
                      style: AppTextStyles.monoSmall.copyWith(
                        color: context.colors.textDisabled,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // % buttons
                  for (final pct in [0.25, 0.5, 0.75]) ...[
                    const SizedBox(width: 5),
                    PctBtn(
                      label: '${(pct * 100).toInt()}%',
                      onTap: widget.onFraction != null ? () => widget.onFraction!(pct) : null,
                    ),
                  ],
                  const SizedBox(width: 5),
                  PctBtn(
                    label: 'MAX',
                    isMax: true,
                    onTap: widget.onMaxPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
