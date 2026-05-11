import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

// ---------------------------------------------------------------------------
// Asset row inside inline dropdown
// ---------------------------------------------------------------------------

class SwapAssetRow extends StatefulWidget {
  const SwapAssetRow({
    required this.asset,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final SwapAsset asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<SwapAssetRow> createState() => _SwapAssetRowState();
}

class _SwapAssetRowState extends State<SwapAssetRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: widget.isSelected
              ? context.colors.primary.withValues(alpha: 0.15)
              : _hovered
              ? context.colors.border.withValues(alpha: 0.4)
              : Colors.transparent,
          child: Row(
            children: [
              TokenIcon(
                symbol: widget.asset.symbol,
                address: widget.asset.tokenAddress,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                widget.asset.symbol,
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colors.textPrimary,
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
                Icon(Icons.check, size: 14, color: context.colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
