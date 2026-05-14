/// Project-wide value formatters.
///
/// All amount/USD parsing and pretty-printing logic lives here so widgets stay
/// presentation-only. If a new format is needed, add it here rather than
/// inline in a widget.
library;

/// Strips everything except digits, dot, and minus sign, then parses.
/// Returns 0 on failure. Handles inputs like `$12.34`, `1,234.56`, `+0.5`.
double parseUsd(String s) => double.tryParse(s.replaceAll(RegExp(r'[^\d.\-]'), '')) ?? 0;

/// Strips everything except digits and dot, then parses.
/// Returns 0 on failure. Use for token balances where minus has no meaning.
double parseAmount(String s) => double.tryParse(s.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

/// Formats an ETH amount string with the given decimal precision and
/// trailing zeros trimmed.
///   `formatEth('1.500000000')`              -> `'1.5'`
///   `formatEth('0')`                        -> `'0.0'`
///   `formatEth('0.006061', decimals: 4)`    -> `'0.0061'`
///   `formatEth('foo')`                      -> `'foo'` (unchanged on parse failure)
///
/// Default `decimals` is 6 — full ETH-side precision for places that
/// want to be exact (Send confirm, History detail). Lower it (e.g. 4)
/// for the Dashboard where the eye scans many numbers at once and full
/// precision becomes visual noise.
String formatEth(String raw, {int decimals = 6}) {
  final v = double.tryParse(raw);
  if (v == null) return raw;
  final s = v.toStringAsFixed(decimals);
  final trimmed = s.replaceAll(RegExp(r'0+$'), '');
  return trimmed.endsWith('.') ? '${trimmed}0' : trimmed;
}

/// Formats a token amount with up to 8 decimals, trailing zeros trimmed.
///   `1.5e-6` -> `'0.0000015'`
///   `0`      -> `''` (empty for zero)
String formatTokenAmount(double v) {
  if (v == 0) return '';
  return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

/// Renders a token-amount string compactly so it fits in tight UI spots.
///
/// Rules:
///   `≥ 1`           → 4 decimals max (`12.34567` → `12.3457`)
///   `0.0001…1`      → 6 decimals max
///   `< 0.0001`      → 8 decimals max (still drops trailing zeros)
///   not parseable   → returned unchanged
///
/// Always trims trailing zeros and a dangling decimal point. Never truncates
/// with `…` — callers can wrap in `Text` without `TextOverflow.ellipsis`.
String formatAmountCompact(String raw) {
  final v = double.tryParse(raw);
  if (v == null) return raw;
  if (v == 0) return '0';

  final abs = v.abs();
  final places = abs >= 1
      ? 4
      : abs >= 0.0001
      ? 6
      : 8;

  final s = v.toStringAsFixed(places);
  if (!s.contains('.')) return s;
  return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

/// Formats a USD value with `$` prefix and adaptive precision.
///   $≥1000 -> `$1.2k`
///   $≥1    -> `$12.34`
///   $<1    -> `$0.0042`
String formatUsd(double v) {
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  if (v >= 1) return '\$${v.toStringAsFixed(2)}';
  return '\$${v.toStringAsFixed(4)}';
}

/// Formats a USD value to fixed 2 decimals (e.g. for totals).
///   `$1234.5` (>=1k)  -> `$1.23k`
///   else              -> `$XX.XX`
String formatUsdFixed(double v) {
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(2)}k';
  return '\$${v.toStringAsFixed(2)}';
}

/// Formats a fraction (0.0 - 1.0) as a percentage with one decimal.
///   `0.1234` -> `'12.3%'`
String formatPercent(double fraction) => '${(fraction * 100).toStringAsFixed(1)}%';

/// Truncates a wallet address: `0x1234...abcd`.
String shortAddress(String address, {int head = 6, int tail = 4}) {
  if (address.length <= head + tail) return address;
  return '${address.substring(0, head)}…${address.substring(address.length - tail)}';
}
