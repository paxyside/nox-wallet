import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

// ---------------------------------------------------------------------------
// Pre-quote meta strip
//
// The swap form leaves a wide empty band between the receive card and the
// Get Quote button until the user fetches a quote. We fill that gap with the
// information we already know up front: route preview, slippage tolerance,
// and current network gas price. Once a real quote comes back the dedicated
// CollapsibleQuote replaces this widget — see SwapForm for the swap.
// ---------------------------------------------------------------------------

class SwapFormMetaRow extends ConsumerWidget {
  const SwapFormMetaRow({
    required this.assetIn,
    required this.assetOut,
    super.key,
  });

  final SwapAsset? assetIn;
  final SwapAsset? assetOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final gasGwei = ref.watch(homeDataProvider).valueOrNull?.gasStats.baseFeeGwei;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          if (assetIn != null && assetOut != null) ...[
            _Row(
              icon: Icons.alt_route_rounded,
              label: 'Route',
              value: _RoutePreview(assetIn: assetIn!, assetOut: assetOut!),
            ),
            const SizedBox(height: 8),
          ],
          _Row(
            icon: Icons.shield_outlined,
            label: 'Max slippage',
            value: Text(
              '0.5%',
              style: AppTextStyles.mono.copyWith(
                color: colors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Row(
            icon: Icons.local_gas_station_outlined,
            label: 'Network',
            value: Text(
              gasGwei == null || gasGwei.isEmpty ? 'Mainnet' : 'Mainnet · $gasGwei Gwei',
              style: AppTextStyles.mono.copyWith(
                color: colors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 13, color: colors.textDisabled),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const Spacer(),
        value,
      ],
    );
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview({required this.assetIn, required this.assetOut});

  final SwapAsset assetIn;
  final SwapAsset assetOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TokenIcon(
          symbol: assetIn.symbol,
          address: assetIn.tokenAddress,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          assetIn.symbol,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.arrow_forward_rounded, size: 11, color: colors.textDisabled),
        const SizedBox(width: 6),
        TokenIcon(
          symbol: assetOut.symbol,
          address: assetOut.tokenAddress,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          assetOut.symbol,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
