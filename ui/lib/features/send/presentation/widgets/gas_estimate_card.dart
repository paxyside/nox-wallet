import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';

/// Combined gas-estimate + speed-picker tile shown above the Send button.
//
// Layout:
//   ┌──────────────────────────────────────────────────────────────────┐
//   │  ⛽ Estimated Gas      │  ⏱ Estimated Time                        │
//   │  0.41 Gwei  $0.02      │  ~12 sec  Fast                          │
//   │ ───────────────────────┴───────────────────────────────────────── │
//   │  Speed             [ Slow ][ Normal ][ Fast ][ Custom ]          │
//   │  (when Custom is selected the tile expands inline)               │
//   │  [Priority gwei]  [Max gwei]                                     │
//   └──────────────────────────────────────────────────────────────────┘
//
// The headline gwei is the cap (max-fee per gas) for the selected tier
// — Slow ×0.85, Normal ×1.00, Fast ×1.25, Custom user-entered. The cap
// moves between tiers, so the reading always changes when the user
// picks a different tier (computed via `SendState.effectiveMaxFeeGwei`).
class GasEstimateCard extends ConsumerWidget {
  const GasEstimateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendNotifierProvider);
    final isEstimating = send.status == SendStatus.estimating;
    final estimate = send.gasEstimate;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: isEstimating
          ? const _LoadingCard(key: ValueKey('loading'))
          : estimate != null
          ? _CombinedCard(key: const ValueKey('estimate'), state: send)
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}

// ── Combined tile (estimate + speed picker + custom inputs) ──────────────────

class _CombinedCard extends ConsumerWidget {
  const _CombinedCard({required this.state, super.key});

  final SendState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sendNotifierProvider.notifier);
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
            const SizedBox(height: 14),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: 12),
            _SpeedRow(tier: state.gasTier, locked: state.isBusy, onChanged: notifier.setGasTier),
            // AnimatedSize handles the expand/collapse without an explicit
            // tween — the child's intrinsic size animates to fit.
            if (showCustom) ...[const SizedBox(height: 12), _CustomGasInputs(state: state)],
          ],
        ),
      ),
    );
  }
}

// ── Estimate row (gas + time, two columns) ───────────────────────────────────

class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.state});

  final SendState state;

  /// Headline gwei = the *cap* (max-fee per gas) the user could pay at
  /// worst. The cap moves between tiers (×0.85 / ×1.0 / ×1.25) so the
  /// reading always changes when the user picks a different tier.
  String get _gweiStr {
    final v = state.effectiveMaxFeeGwei;
    if (v == 0) return '0 Gwei';
    if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
    if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
    return '${v.toStringAsFixed(0)} Gwei';
  }

  /// USD upper bound: gasUnits × cap × 1e-9 × ethPrice.
  String? get _costUsdStr {
    final est = state.gasEstimate;
    if (est == null) return null;
    final price = est.ethPriceUsd;
    if (price == null || price <= 0) return null;
    final gas = est.estimatedGas.toDouble();
    final cap = state.effectiveMaxFeeGwei;
    final usd = gas * cap * 1e-9 * price;
    if (usd <= 0) return null;
    if (usd < 0.01) return r'$' + usd.toStringAsFixed(4);
    return r'$' + usd.toStringAsFixed(2);
  }

  /// Time + label tied to tier. Custom uses a heuristic on the cap vs base.
  ({String time, String speed, Color Function(BuildContext) color}) get _timeInfo {
    switch (state.gasTier) {
      case GasTier.fast:
        return (time: '~12 sec', speed: 'Fast', color: (ctx) => ctx.colors.success);
      case GasTier.normal:
        return (time: '~30 sec', speed: 'Standard', color: (ctx) => ctx.colors.warning);
      case GasTier.slow:
        return (time: '~1 min', speed: 'Slow', color: (ctx) => ctx.colors.error);
      case GasTier.custom:
        // Same heuristic as before for Custom: maxFee vs baseFee ratio.
        final est = state.gasEstimate;
        final base = double.tryParse(est?.baseFee ?? '') ?? 0;
        final cap = state.effectiveMaxFeeGwei;
        if (base <= 0 || cap >= base * 1.5) {
          return (time: '~12 sec', speed: 'Fast', color: (ctx) => ctx.colors.success);
        }
        if (cap >= base * 1.1) {
          return (time: '~30 sec', speed: 'Standard', color: (ctx) => ctx.colors.warning);
        }
        return (time: '~1 min', speed: 'Slow', color: (ctx) => ctx.colors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ti = _timeInfo;
    final speedColor = ti.color(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left column — gas cost ─────────────────────────────────────────
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
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Gas is the fee paid to network validators.',
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: context.colors.textDisabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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

        // Vertical divider
        Container(
          width: 1,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: context.colors.border,
        ),

        // ── Right column — estimated time ──────────────────────────────────
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
              const SizedBox(height: 6),
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

// ── Speed row (label + tier picker) ──────────────────────────────────────────

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

// ── Custom gwei inputs (priority + max) ──────────────────────────────────────

class _CustomGasInputs extends ConsumerStatefulWidget {
  const _CustomGasInputs({required this.state});
  final SendState state;

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
    final n = ref.read(sendNotifierProvider.notifier);
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

// ── Loading + shell ──────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key});

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          'Estimating gas…',
          style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
      ],
    ),
  );
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
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: child),
  );
}
