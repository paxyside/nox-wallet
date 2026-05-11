import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';

// ---------------------------------------------------------------------------
// Overlay-mounted asset list shared by the Send "amount card".
//
// Sibling of swap_asset_list_panel.dart — same visual shell (surface card,
// scaleY+fade intro, scrollable list, hover/selected states), parameterised
// by SendAsset instead of SwapAsset. Both forms now feel like one component.
// ---------------------------------------------------------------------------

class SendAssetListPanel extends StatefulWidget {
  const SendAssetListPanel({
    required this.assets,
    required this.selected,
    required this.onPicked,
    this.width = 300,
    super.key,
  });

  final List<SendAsset> assets;
  final SendAsset? selected;
  final ValueChanged<SendAsset> onPicked;
  final double width;

  @override
  State<SendAssetListPanel> createState() => _SendAssetListPanelState();
}

class _SendAssetListPanelState extends State<SendAssetListPanel> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      opacity: _shown ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topRight,
        scale: _shown ? 1 : 0.94,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final asset in widget.assets)
                    _AssetRow(
                      asset: asset,
                      isSelected: asset == widget.selected,
                      onTap: () => widget.onPicked(asset),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetRow extends StatefulWidget {
  const _AssetRow({
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final SendAsset asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AssetRow> createState() => _AssetRowState();
}

class _AssetRowState extends State<_AssetRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          color: widget.isSelected
              ? context.colors.primary.withValues(alpha: 0.15)
              : _hovered
              ? context.colors.surfaceHigh
              : Colors.transparent,
          child: Row(
            children: [
              TokenIcon(
                symbol: widget.asset.symbol,
                address: widget.asset.tokenAddress,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.asset.symbol,
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.asset.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.asset.balance,
                style: AppTextStyles.monoSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: context.colors.primaryLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
