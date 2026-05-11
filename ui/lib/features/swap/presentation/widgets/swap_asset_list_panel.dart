import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/widgets/swap_asset_row.dart';

// ---------------------------------------------------------------------------
// Overlay-mounted token list shared by SwapPayCard / SwapReceiveCard.
//
// Renders the list of selectable assets as a floating panel (instead of an
// inline-expand inside the card) so the rest of the swap form stays in
// place — earlier the AnimatedSize-based dropdown pushed everything below
// it down by the height of the entire token list, forcing scroll on the
// 720px window.
// ---------------------------------------------------------------------------

class SwapAssetListPanel extends StatefulWidget {
  const SwapAssetListPanel({
    required this.assets,
    required this.selected,
    required this.onPicked,
    this.width = 300,
    super.key,
  });

  final List<SwapAsset> assets;
  final SwapAsset? selected;
  final ValueChanged<SwapAsset> onPicked;
  final double width;

  @override
  State<SwapAssetListPanel> createState() => _SwapAssetListPanelState();
}

class _SwapAssetListPanelState extends State<SwapAssetListPanel> {
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
                    SwapAssetRow(
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
