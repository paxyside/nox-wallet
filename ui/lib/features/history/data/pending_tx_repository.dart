import 'package:nox/core/network/grpc_client.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

/// PendingTxItem is the UI-facing snapshot of an in-flight transaction.
/// All numeric strings are pre-formatted server-side (ETH for value, gwei for
/// gas), so the widget renders them verbatim.
class PendingTxItem {
  const PendingTxItem({
    required this.txHash,
    required this.from,
    required this.to,
    required this.value,
    required this.nonce,
    required this.gasTipGwei,
    required this.gasCapGwei,
    required this.kind,
    required this.submittedAt,
  });

  final String txHash;
  final String from;
  final String to;
  final String value;
  final int nonce;
  final String gasTipGwei;
  final String gasCapGwei;
  final String kind;
  final DateTime submittedAt;
}

abstract interface class PendingTxRepository {
  Future<List<PendingTxItem>> list();
}

class PendingTxGrpcRepository implements PendingTxRepository {
  const PendingTxGrpcRepository();

  @override
  Future<List<PendingTxItem>> list() async {
    final response = await GrpcClient.instance.stub.listPendingTxs(ListPendingTxsRequest());
    return response.pending
        .map(
          (p) => PendingTxItem(
            txHash: p.txHash,
            from: p.from,
            to: p.to,
            value: p.value,
            nonce: p.nonce.toInt(),
            gasTipGwei: p.gasTipGwei,
            gasCapGwei: p.gasCapGwei,
            kind: p.kind,
            submittedAt: p.submittedAt.toDateTime(),
          ),
        )
        .toList();
  }
}
