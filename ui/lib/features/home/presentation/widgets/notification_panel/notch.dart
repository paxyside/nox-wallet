part of '../wallet_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notch
// ─────────────────────────────────────────────────────────────────────────────

class _NotchPainter extends CustomPainter {
  const _NotchPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas
      ..drawPath(
        path,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  @override
  bool shouldRepaint(covariant _NotchPainter old) => old.fill != fill || old.stroke != stroke;
}

extension _PanelFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
