import 'package:nox/core/network/grpc_client.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

/// Replacement-tx (speed-up / cancel) operations on a pending transaction.
abstract interface class ReplacementRepository {
  /// Resubmits the same payload at the original nonce with bumped gas.
  /// Returns the new transaction hash.
  Future<String> speedUp(String txHash);

  /// Submits a 0-value self-transfer at the original nonce with bumped gas.
  /// If it lands first, the original is orphaned.
  Future<String> cancel(String txHash);
}

class ReplacementGrpcRepository implements ReplacementRepository {
  const ReplacementGrpcRepository();

  @override
  Future<String> speedUp(String txHash) async {
    final response = await GrpcClient.instance.stub.speedUpTx(
      SpeedUpTxRequest()..txHash = txHash,
    );
    return response.newTxHash;
  }

  @override
  Future<String> cancel(String txHash) async {
    final response = await GrpcClient.instance.stub.cancelTx(
      CancelTxRequest()..txHash = txHash,
    );
    return response.newTxHash;
  }
}
