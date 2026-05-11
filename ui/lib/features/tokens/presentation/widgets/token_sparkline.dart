import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nox/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Interactive sparkline
// ─────────────────────────────────────────────────────────────────────────────

class TokenSparkline extends StatefulWidget {
  const TokenSparkline({
    required this.points,
    required this.positive,
    required this.height,
    super.key,
  });

  final List<double> points;
  final bool positive;
  final double height;

  @override
  State<TokenSparkline> createState() => _TokenSparklineState();
}

class _TokenSparklineState extends State<TokenSparkline> {
  double? _hoverFraction; // null = not hovered; 0..1 = position along x

  Color get _color => widget.positive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

  double _valueAt(double fraction) {
    if (widget.points.isEmpty) return 0;
    final idx = (fraction * (widget.points.length - 1)).round().clamp(
      0,
      widget.points.length - 1,
    );
    return widget.points[idx];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return MouseRegion(
          onHover: (e) => setState(
            () => _hoverFraction = (e.localPosition.dx / w).clamp(0.0, 1.0),
          ),
          onExit: (_) => setState(() => _hoverFraction = null),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: w,
                height: widget.height,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    points: widget.points,
                    color: _color,
                    hoverFraction: _hoverFraction,
                  ),
                ),
              ),
              // Tooltip: inside the chart area, flips left↔right to avoid edge clipping
              if (_hoverFraction != null)
                Positioned(
                  top: 1,
                  left: _hoverFraction! <= 0.5 ? (_hoverFraction! * w + 8).clamp(0, w - 60) : null,
                  right: _hoverFraction! > 0.5
                      ? ((1 - _hoverFraction!) * w + 8).clamp(0, w - 60)
                      : null,
                  child: _SparklineTooltip(
                    value: _valueAt(_hoverFraction!),
                    color: _color,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SparklineTooltip extends StatelessWidget {
  const _SparklineTooltip({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = value >= 1000
        ? '\$${value.toStringAsFixed(0)}'
        : value >= 1
        ? '\$${value.toStringAsFixed(2)}'
        : '\$${value.toStringAsFixed(4)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
    this.hoverFraction,
  });

  final List<double> points;
  final Color color;
  final double? hoverFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minV = points.reduce(math.min);
    final maxV = points.reduce(math.max);
    final range = maxV - minV;

    const vPad = 4.0;
    final drawH = size.height - vPad * 2;

    Offset pt(int i) {
      final x = size.width * i / (points.length - 1);
      final y = range == 0 ? size.height / 2 : vPad + drawH * (1 - (points[i] - minV) / range);
      return Offset(x, y);
    }

    // ── Smooth line + gradient fill ──────────────────────────────────────────
    final line = Path();
    final fill = Path();
    final first = pt(0);
    line.moveTo(first.dx, first.dy);
    fill
      ..moveTo(first.dx, size.height)
      ..lineTo(first.dx, first.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = pt(i - 1);
      final curr = pt(i);
      final cpX = (prev.dx + curr.dx) / 2;
      line.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
      fill.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();

    canvas
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        line,
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

    // ── Crosshair ────────────────────────────────────────────────────────────
    if (hoverFraction != null) {
      final x = hoverFraction! * size.width;
      // Compute y at hovered index
      final idx = (hoverFraction! * (points.length - 1)).round().clamp(
        0,
        points.length - 1,
      );
      final dotPt = pt(idx);

      // Vertical dashed line
      final dashPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      const dashH = 4.0;
      const dashGap = 3.0;
      var y = 0.0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + dashH, size.height)),
          dashPaint,
        );
        y += dashH + dashGap;
      }

      // Dot at the line
      canvas
        ..drawCircle(
          dotPt,
          4,
          Paint()..color = color,
        )
        ..drawCircle(
          dotPt,
          2.5,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points || old.color != color || old.hoverFraction != hoverFraction;
}
