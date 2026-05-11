// Small presentation-only formatters shared across notification surfaces
// (panel tiles, OS toast copy). Intentionally has no Flutter dependency so
// it can be unit-tested without a binding.

import 'package:intl/intl.dart';

/// Formats a numeric amount string for compact display.
///
/// - Rounds to at most [maxFrac] fractional digits.
/// - Strips trailing zeros after the decimal point ("1.000000" → "1").
/// - Returns the original [raw] string when it doesn't parse as a double
///   (e.g. "<0.000001" placeholder, "Unknown") so callers don't lose the
///   sentinel.
String formatAmount(String raw, {int maxFrac = 6}) {
  if (raw.isEmpty) return raw;
  final v = double.tryParse(raw);
  if (v == null) return raw;
  if (v == 0) return '0';

  // toStringAsFixed handles negatives + IEEE-754 rounding consistently.
  var s = v.toStringAsFixed(maxFrac);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Human-readable relative time. Buckets:
///
/// - < 1 min  → "just now"
/// - < 1 hour → "Nm ago"
/// - < 1 day  → "Nh ago"
/// - < 7 days → "Nd ago"
/// - older    → "MMM d" (e.g. "May 6")
///
/// [now] is injectable for deterministic tests.
String timeAgo(DateTime t, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(t);

  // Future timestamps (clock skew) collapse to "just now".
  if (diff.isNegative || diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(t);
}
