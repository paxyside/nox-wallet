import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/widgets/swap_asset_list_panel.dart';

// ---------------------------------------------------------------------------
// "You receive" card — read-only amount, token selector
// ---------------------------------------------------------------------------

class SwapReceiveCard extends ConsumerStatefulWidget {
  const SwapReceiveCard({
    required this.assets,
    required this.selected,
    required this.locked,
    required this.value,
    required this.onAssetChanged,
    super.key,
  });

  final List<SwapAsset> assets;
  final SwapAsset? selected;
  final bool locked;
  final String? value;
  final ValueChanged<SwapAsset> onAssetChanged;

  @override
  ConsumerState<SwapReceiveCard> createState() => _SwapReceiveCardState();
}

class _SwapReceiveCardState extends ConsumerState<SwapReceiveCard> {
  final _selectorLink = LayerLink();
  OverlayEntry? _entry;
  bool _selectorOpen = false;

  bool get _canOpen => !widget.locked && widget.assets.length > 1;

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

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
    final s = widget.selected;
    final borderColor = _selectorOpen
        ? context.colors.primary.withValues(alpha: 0.55)
        : context.colors.border;
    final quoting = ref.watch(
      swapNotifierProvider.select((st) => st.status == SwapStatus.quoting),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Tag — same pattern as the Pay card. ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
              child: Text(
                'RECEIVE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colors.textDisabled,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // ── Read-only amount (left) + token selector (right) ───────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Read-only amount — left
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 10, 8),
                    child: quoting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Calculating…',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : MaskableText(
                            widget.value ?? '0.00',
                            style: AppTextStyles.mono.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: widget.value == null
                                  ? context.colors.textDisabled
                                  : context.colors.success,
                            ),
                          ),
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

            // ── Balance ──────────────────────────────────────────────────
            if (s != null) ...[
              Divider(height: 1, color: context.colors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                child: Row(
                  children: [
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
