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

/// 4-segment selector with a sliding indicator pill — the highlight
/// AnimatedPositioned'd between segments instead of fading per-segment
/// AnimatedContainer's, mirroring the Auto-delete control in the
/// notifications panel so the app's "segmented selectors" share one
/// visual language.
///
/// Segments share the parent row's width equally (Expanded) so the
/// indicator can locate each segment as `index * (totalWidth / N)`
/// without runtime text measurement.
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

  /// Reserved for API compatibility with earlier non-expand usage —
  /// no callers pass false today, but keeping the parameter avoids
  /// breaking the public constructor.
  final bool expand;

  static const _innerPad = 2.0;
  static const _radius = 8.0;
  static const _indicatorRadius = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const tiers = GasTier.values;
    final selectedIndex = tiers.indexOf(selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Available width inside the outer container (minus its 2px
        // padding on each side). Each segment owns 1/N of that width;
        // the sliding indicator slides to `index * segmentWidth`.
        final innerWidth = constraints.maxWidth - _innerPad * 2;
        final segmentWidth = innerWidth / tiers.length;

        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceHigh,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.all(_innerPad),
          child: Stack(
            children: [
              // Sliding indicator — same easing/duration family as
              // MiniSwitch and the Auto-delete segmented control.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(_indicatorRadius),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final t in tiers)
                    Expanded(
                      child: _Segment(
                        tier: t,
                        isSelected: t == selected,
                        onTap: locked ? null : () => onChanged(t),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({required this.tier, required this.isSelected, required this.onTap});

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
        behavior: HitTestBehavior.opaque,
        // No per-segment background — the sliding indicator in the
        // parent Stack owns the highlight. Each segment just renders
        // icon+label and animates text colour for a smooth selection
        // transition (no jumpy colour swap mid-slide).
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  widget.tier.icon,
                  size: 12,
                  color: fg,
                  key: ValueKey('${widget.tier}_${widget.isSelected}_$_hovered'),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: AppTextStyles.labelMedium.copyWith(
                  color: fg,
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(widget.tier.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
