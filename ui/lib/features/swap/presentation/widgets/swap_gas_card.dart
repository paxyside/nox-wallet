import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

/// Combined gas-estimate + speed-picker tile for the Swap screen. Mirrors
/// the Send-side `GasEstimateCard` so both forms have identical UX, but
/// reads from `swapNotifierProvider` instead.
//
// Layout:
//   ┌──────────────────────────────────────────────────────────────────┐
//   │  ⛽ Estimated Gas      │  ⏱ Estimated Time                        │
//   │  0.41 Gwei  $0.14      │  ~12 sec  Fast                          │
//   │ ─────────────────────── divider ─────────────────────────────────│
//   │  Speed             [ Slow ][ Normal ][ Fast ][ Custom ]          │
//   │  (Custom expands the tile inline)                                │
//   │  [Priority gwei]  [Max gwei]                                     │
//   └──────────────────────────────────────────────────────────────────┘
class SwapGasCard extends ConsumerWidget {
  const SwapGasCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(swapNotifierProvider);
    if (state.quote == null) return const SizedBox.shrink();

    final notifier = ref.read(swapNotifierProvider.notifier);
    final showCustom = state.gasTier == GasTier.custom;

    return _CardShell(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _EstimateRow(state: state),
            const SizedBox(height: 10),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: 10),
            _SpeedRow(tier: state.gasTier, locked: state.isLoading, onChanged: notifier.setGasTier),
            if (showCustom) ...[const SizedBox(height: 10), _CustomGasInputs(state: state)],
          ],
        ),
      ),
    );
  }
}

// ── Estimate row (gas + time, two columns) ───────────────────────────────────

class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.state});

  final SwapState state;

  String get _gweiStr {
    final v = state.effectiveMaxFeeGwei;
    if (v == 0) return '0 Gwei';
    if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
    if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
    return '${v.toStringAsFixed(0)} Gwei';
  }

  /// Pre-existing gasCostUsd from the quote is computed at the network
  /// suggestion. We rescale it to the active tier's cap so the USD line
  /// matches the headline gwei.
  String? get _costUsdStr {
    final q = state.quote;
    if (q == null) return null;
    final usdRaw = q.gasCostUsd;
    if (usdRaw == null || usdRaw.isEmpty) return null;
    // gasCostUsd looks like "$1.23"; strip and rescale.
    final cleaned = usdRaw.replaceAll(RegExp('[^0-9.]'), '');
    final v = double.tryParse(cleaned);
    final baseMax = double.tryParse(q.maxFeeGwei ?? '');
    if (v == null || baseMax == null || baseMax == 0) return usdRaw;
    final scaled = v * (state.effectiveMaxFeeGwei / baseMax);
    if (scaled <= 0) return null;
    if (scaled < 0.01) return '\$${scaled.toStringAsFixed(4)}';
    return '\$${scaled.toStringAsFixed(2)}';
  }

  ({String time, String speed, Color Function(BuildContext) color}) get _timeInfo {
    switch (state.gasTier) {
      case GasTier.fast:
        return (time: '~12 sec', speed: 'Fast', color: (ctx) => ctx.colors.success);
      case GasTier.normal:
        return (time: '~30 sec', speed: 'Standard', color: (ctx) => ctx.colors.warning);
      case GasTier.slow:
        return (time: '~1 min', speed: 'Slow', color: (ctx) => ctx.colors.error);
      case GasTier.custom:
        return (time: 'custom', speed: 'Custom', color: (ctx) => ctx.colors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ti = _timeInfo;
    final speedColor = ti.color(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.local_gas_station_rounded, size: 16, color: context.colors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated Gas',
                    style: AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _gweiStr,
                    style: AppTextStyles.mono.copyWith(
                      color: context.colors.primaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_costUsdStr != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _costUsdStr!,
                      style: AppTextStyles.mono.copyWith(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          color: context.colors.border,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: context.colors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated Time',
                    style: AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ti.time,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: speedColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      ti.speed,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: speedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({required this.tier, required this.locked, required this.onChanged});

  final GasTier tier;
  final bool locked;
  final ValueChanged<GasTier> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Speed', style: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled)),
        const SizedBox(width: 16),
        Expanded(
          child: GasTierPicker(selected: tier, onChanged: onChanged, locked: locked, expand: true),
        ),
      ],
    );
  }
}

class _CustomGasInputs extends ConsumerStatefulWidget {
  const _CustomGasInputs({required this.state});
  final SwapState state;

  @override
  ConsumerState<_CustomGasInputs> createState() => _CustomGasInputsState();
}

class _CustomGasInputsState extends ConsumerState<_CustomGasInputs> {
  late final TextEditingController _priorityCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _priorityCtrl = TextEditingController(text: widget.state.customPriorityGwei);
    _maxCtrl = TextEditingController(text: widget.state.customMaxGwei);
  }

  @override
  void dispose() {
    _priorityCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = ref.read(swapNotifierProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: _gweiField(
            context,
            controller: _priorityCtrl,
            label: 'Priority (gwei)',
            onChanged: n.setCustomPriorityGwei,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _gweiField(
            context,
            controller: _maxCtrl,
            label: 'Max (gwei)',
            onChanged: n.setCustomMaxGwei,
          ),
        ),
      ],
    );
  }

  Widget _gweiField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.mono.copyWith(color: context.colors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.colors.border),
    ),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: child),
  );
}
