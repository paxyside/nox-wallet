// Domain models and abstract repository for the Send feature.

import 'package:nox/core/gas/gas_override.dart';

export 'package:nox/core/gas/gas_override.dart' show GasOverride;

class TxResult {
  const TxResult({required this.txHash, required this.success});

  final String txHash;
  final bool success;
}

class GasEstimate {
  const GasEstimate({
    required this.baseFee,
    required this.priorityFee,
    required this.maxFee,
    required this.estimatedGas,
    this.ethPriceUsd,
  });

  /// All three are decimal gwei strings, sourced from the network's gas
  /// suggestion. `maxFee = baseFee + priorityFee` is NOT guaranteed: the
  /// node returns its own maxFee (typically `2×baseFee + priorityFee`).
  final String baseFee;
  final String priorityFee;
  final String maxFee;

  final int estimatedGas;
  final double? ethPriceUsd; // null if price feed unavailable
}

abstract class SendRepository {
  Future<TxResult> sendEth(String toAddress, String amount, {GasOverride gas = GasOverride.auto});
  Future<TxResult> sendToken(
    String toAddress,
    String tokenAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  });
  Future<GasEstimate> getGasEstimate();
}
