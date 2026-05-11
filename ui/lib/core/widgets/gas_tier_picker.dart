import 'package:flutter/material.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

/// EIP-1559 gas tier preset.
///
/// Each tier has TWO multipliers — one for the priority (validator tip) and
/// one for the maxFee cap. The cap multiplier is what makes the displayed
/// "headline" gwei meaningfully different across tiers when the network is
/// uncongested (where priority alone is too small to budge the reading):
///   - Slow:   priority 0.7× / cap 0.85×  (cheaper bound, may take longer)
///   - Normal: priority 1.0× / cap 1.00×  (network suggestion)
///   - Fast:   priority 1.5× / cap 1.25×  (bump to outbid congestion)
///   - Custom: user-entered values; multipliers unused
enum GasTier {
  slow,
  normal,
  fast,
  custom
  ;

  String get label => switch (this) {
    GasTier.slow => 'Slow',
    GasTier.normal => 'Normal',
    GasTier.fast => 'Fast',
    GasTier.custom => 'Custom',
  };

  /// Multiplier vs the network's suggested priority fee. Custom returns 1
  /// because the actual values come from the user; the multiplier is unused.
  double get priorityMultiplier => switch (this) {
    GasTier.slow => 0.7,
    GasTier.normal => 1.0,
    GasTier.fast => 1.5,
    GasTier.custom => 1.0,
  };

  /// Multiplier vs the network-suggested maxFee cap. Slow trims the cap so
  /// the "max you might pay" reading reflects a cheaper choice; Fast bumps
  /// it so the elevated tip isn't squashed under congestion.
  double get maxFeeMultiplier => switch (this) {
    GasTier.slow => 0.85,
    GasTier.normal => 1.0,
    GasTier.fast => 1.25,
    GasTier.custom => 1.0,
  };

  IconData get icon => switch (this) {
    GasTier.slow => Icons.eco_outlined,
    GasTier.normal => Icons.local_gas_station_outlined,
    GasTier.fast => Icons.bolt_rounded,
    GasTier.custom => Icons.tune_rounded,
  };
}

/// 4-segment selector that mirrors the History direction toggle so the
/// visual language stays consistent. When [expand] is true, the segments
/// share the parent row's width equally — useful inside the gas card where
/// the picker should stretch across the row instead of hugging its label.
class GasTierPicker extends StatelessWidget {
  const GasTierPicker({
    required this.selected,
    required this.onChanged,
    this.locked = false,
    this.expand = false,
    super.key,
  });

  final GasTier selected;
  final ValueChanged<GasTier> onChanged;
  final bool locked;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final t in GasTier.values)
            if (expand)
              Expanded(
                child: _Segment(
                  tier: t,
                  isSelected: t == selected,
                  onTap: locked ? null : () => onChanged(t),
                ),
              )
            else
              _Segment(
                tier: t,
                isSelected: t == selected,
                onTap: locked ? null : () => onChanged(t),
              ),
        ],
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  final GasTier tier;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = widget.isSelected
        ? colors.primaryLight
        : _hovered
        ? colors.textPrimary
        : colors.textSecondary;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isSelected ? colors.primary.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? colors.primary.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.tier.icon, size: 12, color: fg),
              const SizedBox(width: 4),
              Text(
                widget.tier.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: fg,
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
