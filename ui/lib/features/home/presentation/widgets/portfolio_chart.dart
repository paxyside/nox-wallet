import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Token colour palette
// ─────────────────────────────────────────────────────────────────────────────

const _knownColors = <String, Color>{
  'ETH': Color(0xFF627EEA),
  'USDC': Color(0xFF2775CA),
  'USDT': Color(0xFF26A17B),
  'DAI': Color(0xFFF5AC37),
  'UNI': Color(0xFFFF007A),
  'WBTC': Color(0xFFF7931A),
  'LINK': Color(0xFF375BD2),
  'AAVE': Color(0xFF9C64DA),
  'MATIC': Color(0xFF8247E5),
  'OP': Color(0xFFFF0420),
  'ARB': Color(0xFF28A0F0),
};

const _fallback = [
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF06B6D4),
  Color(0xFFEC4899),
];

Color _colorFor(String symbol, int index) =>
    _knownColors[symbol.toUpperCase()] ?? _fallback[index % _fallback.length];

// ─────────────────────────────────────────────────────────────────────────────
// Slice model
// ─────────────────────────────────────────────────────────────────────────────

class _Slice {
  const _Slice({
    required this.label,
    required this.usd,
    required this.fraction,
    required this.color,
  });

  final String label;
  final double usd;
  final double fraction;
  final Color color;

  String get pct => '${(fraction * 100).toStringAsFixed(1)}%';
  String get usdStr {
    if (usd >= 1000) return '\$${(usd / 1000).toStringAsFixed(1)}k';
    if (usd >= 1) return '\$${usd.toStringAsFixed(2)}';
    return '\$${usd.toStringAsFixed(4)}';
  }
}

double _parseUsd(String s) => double.tryParse(s.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

/// Maximum number of slices shown in the dashboard donut. Mirrors the
/// dashboard token list so the two blocks stay visually consistent.
const _maxTokens = 4;

/// Fallback path when `tokensNotifierProvider` hasn't enriched balances with
/// USD yet — we read straight from `BalanceData.tokens` (already has USD
/// from `GetBalances`). Same pinned-first / USD-desc semantics as above; the
/// fallback list has no pinning info, so we sort purely by USD descending.
List<MapEntry<String, double>> _fromBalanceData(BalanceData data) {
  final items = [for (final t in data.tokens) MapEntry(t.symbol, _parseUsd(t.usdValue))]
    ..sort((a, b) => b.value.compareTo(a.value));
  return items.take(_maxTokens).toList();
}

/// Builds slices from an already-ordered list of `(symbol, usd)` entries.
/// Caller is responsible for sorting (pinned-first → USD desc) and slicing
/// to the desired count, so this component matches the dashboard token list
/// exactly. ETH is intentionally excluded — the wallet header already shows
/// the native balance prominently.
List<_Slice> _buildSlices(List<MapEntry<String, double>> ordered) {
  final positive = ordered.where((e) => e.value > 0).toList();
  if (positive.isEmpty) return [];
  final total = positive.fold<double>(0, (s, e) => s + e.value);
  if (total == 0) return [];

  return [
    for (var i = 0; i < positive.length; i++)
      _Slice(
        label: positive[i].key,
        usd: positive[i].value,
        fraction: positive[i].value / total,
        color: _colorFor(positive[i].key, i),
      ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut geometry constants
// ─────────────────────────────────────────────────────────────────────────────

const _donutSize = 150.0;
const _strokeW = 24.0;
const _hoveredStrokeW = 30.0;
const double _donutRadius = _donutSize / 2 - _hoveredStrokeW / 2 - 2;
const _donutGap = 0.025; // radians between slices

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class PortfolioChart extends ConsumerStatefulWidget {
  const PortfolioChart({required this.balanceData, super.key});
  final BalanceData balanceData;

  @override
  ConsumerState<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends ConsumerState<PortfolioChart> {
  _Slice? _hoveredSlice;

  // Each hover change bumps this counter so AnimatedSwitcher always gets a
  // unique key — prevents "Duplicate keys" crash when re-entering the same
  // slice before the 180 ms exit animation finishes.
  int _centerKeyVersion = 0;

  void _setHover(_Slice? slice) {
    if (_hoveredSlice == slice) return;
    setState(() {
      _hoveredSlice = slice;
      _centerKeyVersion++;
    });
  }

  // ── Slice hit-test ──────────────────────────────────────────────────────────

  _Slice? _hitTest(Offset local, List<_Slice> slices) {
    const cx = _donutSize / 2;
    const cy = _donutSize / 2;
    final dx = local.dx - cx;
    final dy = local.dy - cy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < _donutRadius - _strokeW / 2 - 6 || dist > _donutRadius + _strokeW / 2 + 6) {
      return null;
    }

    var angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    double start = 0;
    for (final slice in slices) {
      final sweep = 2 * pi * slice.fraction - _donutGap;
      if (sweep <= 0) {
        start += _donutGap;
        continue;
      }
      if (angle >= start && angle < start + sweep + _donutGap / 2) return slice;
      start += sweep + _donutGap;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Source of truth: same `tokensNotifierProvider` the dashboard token list
    // consumes. Order is pinned-first → USD desc, take top [_maxTokens]. ETH
    // is intentionally excluded — it lives in the wallet header card.
    //
    // While the price feed is still resolving (every `balanceUsd` is empty),
    // we fall back to `balanceData.tokens` which already carries USD from
    // GetBalances. Otherwise the donut would briefly collapse to "no data".
    final watched = ref.watch(tokensNotifierProvider).valueOrNull ?? const [];
    final ordered = <MapEntry<String, double>>[];
    if (watched.isNotEmpty) {
      final sorted = [...watched]
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return _parseUsd(b.balanceUsd).compareTo(_parseUsd(a.balanceUsd));
        });
      for (final w in sorted.take(_maxTokens)) {
        ordered.add(MapEntry(w.symbol, _parseUsd(w.balanceUsd)));
      }
      // If price feed hasn't enriched any of them yet, fall back to
      // balanceData.tokens for that frame.
      if (ordered.every((e) => e.value == 0)) {
        ordered
          ..clear()
          ..addAll(_fromBalanceData(widget.balanceData));
      }
    } else {
      ordered.addAll(_fromBalanceData(widget.balanceData));
    }

    final slices = _buildSlices(ordered);
    final total = slices.fold<double>(0, (s, e) => s + e.usd);
    final totalStr = total >= 1000
        ? '\$${(total / 1000).toStringAsFixed(2)}k'
        : '\$${total.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.surfaceHigh, context.colors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          // "View all" navigates to the dedicated Tokens screen — lives
          // as a tooltip'd icon-button on the right of the title so the
          // header carries the action (matches the Tokens card's "+
          // Add Token" placement on the dashboard). Frees the bottom
          // of the card for the actual portfolio content.
          Row(
            children: [
              Expanded(
                child: Text(
                  'Portfolio',
                  style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
                ),
              ),
              if (slices.isNotEmpty) _ViewAllButton(onTap: () => context.go(Routes.tokens)),
            ],
          ),
          const SizedBox(height: 12),

          if (slices.isEmpty)
            _EmptyChart()
          else ...[
            // ── Donut + Legend side by side ────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut
                MouseRegion(
                  onExit: (_) => _setHover(null),
                  child: Listener(
                    onPointerHover: (e) {
                      _setHover(_hitTest(e.localPosition, slices));
                    },
                    child: SizedBox(
                      width: _donutSize,
                      height: _donutSize,
                      child: Stack(
                        children: [
                          CustomPaint(
                            painter: _DonutPainter(
                              slices: slices,
                              hoveredSlice: _hoveredSlice,
                              trackColor: context.colors.surfaceHigh,
                            ),
                            child: const SizedBox.expand(),
                          ),
                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: _hoveredSlice != null
                                  ? _DonutCenter.slice(
                                      _hoveredSlice!,
                                      key: ValueKey('slice_$_centerKeyVersion'),
                                    )
                                  : _DonutCenter.total(
                                      totalStr,
                                      context,
                                      key: ValueKey('total_$_centerKeyVersion'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final slice in slices) ...[
                        _LegendRow(
                          slice: slice,
                          isHovered: _hoveredSlice == slice,
                          onEnter: () => _setHover(slice),
                          onExit: () => _setHover(null),
                        ),
                        if (slice != slices.last) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend row — highlights on hover, mirrors donut hover state
// ─────────────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.isHovered,
    required this.onEnter,
    required this.onExit,
  });

  final _Slice slice;
  final bool isHovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final dotColor = isHovered ? slice.color : slice.color.withValues(alpha: 0.75);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isHovered ? slice.color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered ? slice.color.withValues(alpha: 0.22) : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Colour dot ───────────────────────────────────────────────
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: isHovered
                    ? [BoxShadow(color: slice.color.withValues(alpha: 0.5), blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: 8),

            // ── Symbol + USD (two lines, takes remaining space) ──────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isHovered ? slice.color : context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  MaskableText(
                    slice.usdStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // ── Percentage (right side) ──────────────────────────────────
            Text(
              slice.pct,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isHovered ? slice.color : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center label inside the donut — swaps between total and hovered slice info
// ─────────────────────────────────────────────────────────────────────────────

class _DonutCenter extends StatelessWidget {
  const _DonutCenter._({
    required this.line1,
    required this.line2,
    required this.line1Color,
    required this.line1Sensitive,
    super.key,
  });

  factory _DonutCenter.total(String totalStr, BuildContext context, {Key? key}) => _DonutCenter._(
    key: key,
    line1: totalStr,
    line2: 'Total',
    line1Color: context.colors.textPrimary,
    line1Sensitive: true,
  );

  factory _DonutCenter.slice(_Slice slice, {Key? key}) => _DonutCenter._(
    key: key,
    line1: slice.pct,
    line2: slice.label,
    line1Color: slice.color,
    line1Sensitive: false,
  );

  final String line1;
  final String line2;
  final Color line1Color;
  final bool line1Sensitive;

  @override
  Widget build(BuildContext context) {
    final line1Style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: line1Color,
      height: 1.1,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (line1Sensitive)
          MaskableText(line1, style: line1Style)
        else
          Text(line1, style: line1Style),
        const SizedBox(height: 2),
        Text(
          line2,
          style: TextStyle(fontSize: 11, color: context.colors.textSecondary, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 36, color: context.colors.textDisabled),
            const SizedBox(height: 10),
            Text(
              'No asset data yet',
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut painter — highlights hovered slice with thicker stroke
// ─────────────────────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.slices, required this.trackColor, this.hoveredSlice});

  final List<_Slice> slices;
  final _Slice? hoveredSlice;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background track
    canvas.drawCircle(
      center,
      _donutRadius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _hoveredStrokeW + 2,
    );

    var startAngle = -pi / 2;
    for (final slice in slices) {
      final sweep = 2 * pi * slice.fraction - _donutGap;
      if (sweep <= 0) continue;

      final isHovered = hoveredSlice == slice;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: _donutRadius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = isHovered ? slice.color : slice.color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHovered ? _hoveredStrokeW : _strokeW
          ..strokeCap = StrokeCap.butt,
      );

      startAngle += sweep + _donutGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.hoveredSlice != hoveredSlice || old.trackColor != trackColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// "View all" header icon-button — mirrors the Add Token / Notification
// bell affordance so the three Dashboard cards share one mini-icon-button
// language for their header actions.
// ─────────────────────────────────────────────────────────────────────────────

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'View all tokens',
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _hovered ? context.colors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: _hovered ? context.colors.textPrimary : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
