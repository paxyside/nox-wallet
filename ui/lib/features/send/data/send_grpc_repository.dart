import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/send/domain/send_repository.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

class SendGrpcRepository implements SendRepository {
  const SendGrpcRepository();

  @override
  Future<GasEstimate> getGasEstimate() async {
    final response = await GrpcClient.instance.stub.getGasFees(GetGasFeesRequest());
    final fees = response.fees;
    final priceStr = response.ethPriceUsd;
    final ethPrice = priceStr.isEmpty ? null : double.tryParse(priceStr);
    return GasEstimate(
      baseFee: fees.baseFeeGwei,
      priorityFee: fees.maxPriorityFeeGwei,
      maxFee: fees.maxFeeGwei,
      estimatedGas: fees.estimatedGas.toInt(),
      ethPriceUsd: ethPrice,
    );
  }

  @override
  Future<TxResult> sendEth(
    String toAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  }) async {
    final request = SendETHRequest()
      ..to = toAddress
      ..amount = amount;
    if (!gas.isEmpty) request.gas = _toProto(gas);
    final response = await GrpcClient.instance.stub.sendETH(request);
    return TxResult(txHash: response.receipt.txHash, success: response.receipt.success);
  }

  @override
  Future<TxResult> sendToken(
    String toAddress,
    String tokenAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  }) async {
    final request = SendTokenRequest()
      ..to = toAddress
      ..tokenAddress = tokenAddress
      ..amount = amount;
    if (!gas.isEmpty) request.gas = _toProto(gas);
    final response = await GrpcClient.instance.stub.sendToken(request);
    return TxResult(txHash: response.receipt.txHash, success: response.receipt.success);
  }

  GasOptions _toProto(GasOverride g) {
    final out = GasOptions();
    if (g.priorityGwei != null) out.priorityGwei = g.priorityGwei!;
    if (g.maxGwei != null) out.maxGwei = g.maxGwei!;
    return out;
  }
}
