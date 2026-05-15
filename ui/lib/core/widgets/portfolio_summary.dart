import 'package:nox/core/balance/balance_repository.dart';

/// Result of summing every priced asset in the wallet — native ETH
/// plus each tracked token with a non-empty USD value. Tokens without
/// a price (empty `usdValue`, fresh contract, pricefeed warming up)
/// contribute zero and are excluded from `assetCount` so the readout
/// reads as "N priced assets", not "N tracked rows including unknowns".
///
/// Returns `null` when fewer than two assets are priced — in that
/// case the headline (native ETH USD value) already conveys all the
/// useful information, and surfacing a separate "Portfolio total"
/// figure would just duplicate it.
typedef PortfolioSummary = ({double totalUsd, int assetCount});

PortfolioSummary? computePortfolioSummary(String ethUsd, List<TokenBalance> tokens) {
  final ethVal = double.tryParse(ethUsd.replaceAll(r'$', '').replaceAll(',', ''));
  var total = 0.0;
  var count = 0;
  if (ethVal != null && ethVal > 0) {
    total += ethVal;
    count += 1;
  }
  for (final t in tokens) {
    if (t.usdValue.isEmpty) continue;
    final v = double.tryParse(t.usdValue.replaceAll(r'$', '').replaceAll(',', ''));
    if (v == null || v <= 0) continue;
    total += v;
    count += 1;
  }
  if (count <= 1) return null;
  return (totalUsd: total, assetCount: count);
}

/// Format a portfolio total in USD with thousands separator + 2
/// decimals — `$1,932.04`. The global `formatUsdFixed` abbreviates
/// ≥1k as `$1.93k` which trades precision for compactness; surfaces
/// that show a portfolio total are typically used to plan transfers,
/// so the user wants the exact figure.
String formatPortfolioTotal(double v) {
  final fixed = v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '\$$buf.${parts[1]}';
}
