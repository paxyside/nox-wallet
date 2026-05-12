import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Change badge — with directional arrow
// ─────────────────────────────────────────────────────────────────────────────

class TokenChangeBadge extends StatelessWidget {
  const TokenChangeBadge({
    required this.change,
    required this.positive,
    required this.color,
    super.key,
  });

  final String change;
  final bool positive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (change.isEmpty) return const SizedBox.shrink();

    // Strip sign from string — we show the arrow instead
    final display = change.replaceAll(RegExp(r'^[+\-]'), '');
    // Flat change → no directional arrow (avoids "↓ 0.00%" misreading).
    final isFlat = display == '0.00';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFlat) ...[
            Icon(
              positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 9,
              color: color,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            '$display%',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
