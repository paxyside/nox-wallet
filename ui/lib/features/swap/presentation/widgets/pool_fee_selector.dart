import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

/// Segmented control for selecting the Uniswap V3 pool fee tier.
class PoolFeeSelector extends ConsumerWidget {
  const PoolFeeSelector({super.key});

  static const List<({String label, int value})> _fees = [
    (label: '0.01%', value: 100),
    (label: '0.05%', value: 500),
    (label: '0.30%', value: 3000),
    (label: '1.00%', value: 10000),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(swapNotifierProvider.select((s) => s.poolFee));
    final notifier = ref.read(swapNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pool fee',
          style: AppTextStyles.labelMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.colors.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: _fees.map((fee) {
              final isSelected = fee.value == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => notifier.setPoolFee(fee.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        fee.label,
                        style: isSelected
                            ? AppTextStyles.labelLarge.copyWith(
                                color: context.colors.textPrimary,
                              )
                            : AppTextStyles.labelMedium.copyWith(
                                color: context.colors.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
