class SwapQuote {
  const SwapQuote({
    required this.amountOut,
    required this.amountOutRaw,
    required this.gasEstimate,
    this.gasCostUsd,
    this.maxFeeGwei,
  });

  final String amountOut;
  final String amountOutRaw;
  final String gasEstimate;
  final String? gasCostUsd; // e.g. "$1.23"  — null if unavailable
  final String? maxFeeGwei; // e.g. "10.50"  — null if unavailable
}
