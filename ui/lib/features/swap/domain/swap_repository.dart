import 'package:nox/core/gas/gas_override.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';

class TxResult {
  const TxResult({required this.txHash, required this.success});

  final String txHash;
  final bool success;
}

abstract class SwapRepository {
  /// Fetches a quote for the given token pair and amount.
  Future<SwapQuote> quote(String tokenIn, String tokenOut, String amountIn, int poolFee);

  /// Executes the swap and returns the transaction result.
  ///
  /// `gas` lets the caller override the EIP-1559 priority + max fees. The
  /// default (`GasOverride.auto`) uses the network suggestion.
  Future<TxResult> execute(
    String tokenIn,
    String tokenOut,
    String amountIn,
    String amountOutMin,
    int poolFee, {
    GasOverride gas = GasOverride.auto,
  });
}
