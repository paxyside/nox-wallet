import 'package:nox/core/gas/gas_override.dart';
import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/domain/swap_repository.dart';
import 'package:wallet_proto/wallet/service.pb.dart';
import 'package:wallet_proto/wallet/swap/swap.pb.dart' as $swappb;

class SwapGrpcRepository implements SwapRepository {
  const SwapGrpcRepository();

  $swappb.PoolFee _toProtoFee(int poolFee) {
    switch (poolFee) {
      case 100:
        return $swappb.PoolFee.POOL_FEE_100;
      case 500:
        return $swappb.PoolFee.POOL_FEE_500;
      case 3000:
        return $swappb.PoolFee.POOL_FEE_3000;
      case 10000:
        return $swappb.PoolFee.POOL_FEE_10000;
      default:
        return $swappb.PoolFee.POOL_FEE_3000;
    }
  }

  @override
  Future<SwapQuote> quote(String tokenIn, String tokenOut, String amountIn, int poolFee) async {
    final request = QuoteSwapRequest()
      ..tokenIn = tokenIn
      ..tokenOut = tokenOut
      ..amountIn = amountIn
      ..fee = _toProtoFee(poolFee);

    final response = await GrpcClient.instance.stub.quoteSwap(request);

    final q = response.quote;
    return SwapQuote(
      amountOut: q.amountOut,
      amountOutRaw: q.amountOutRaw,
      gasEstimate: q.gasEstimate,
      gasCostUsd: q.gasCostUsd.isEmpty ? null : q.gasCostUsd,
      maxFeeGwei: q.maxFeeGwei.isEmpty ? null : q.maxFeeGwei,
    );
  }

  @override
  Future<TxResult> execute(
    String tokenIn,
    String tokenOut,
    String amountIn,
    String amountOutMin,
    int poolFee, {
    GasOverride gas = GasOverride.auto,
  }) async {
    final request = ExecuteSwapRequest()
      ..tokenIn = tokenIn
      ..tokenOut = tokenOut
      ..amountIn = amountIn
      ..amountOutMin = amountOutMin
      ..fee = _toProtoFee(poolFee)
      ..deadlineSeconds = 300;

    if (!gas.isEmpty) {
      final opts = GasOptions();
      if (gas.priorityGwei != null) opts.priorityGwei = gas.priorityGwei!;
      if (gas.maxGwei != null) opts.maxGwei = gas.maxGwei!;
      request.gas = opts;
    }

    final response = await GrpcClient.instance.stub.executeSwap(request);

    return TxResult(txHash: response.receipt.txHash, success: response.receipt.success);
  }
}
