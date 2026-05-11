import 'package:nox/core/network/grpc_client.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

/// One asset diff returned by alchemy_simulateAssetChanges. Empty list
/// means the backend used the eth_call fallback (no diff info available).
class SimulatedAssetChange {
  const SimulatedAssetChange({
    required this.kind,
    required this.changeType,
    required this.from,
    required this.to,
    required this.amount,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.contractAddress,
    required this.tokenId,
  });

  final String kind; // NATIVE | ERC20 | ERC721 | ERC1155 | SPECIAL
  final String changeType; // TRANSFER | APPROVE
  final String from;
  final String to;
  final String amount;
  final String symbol;
  final String name;
  final int decimals;
  final String contractAddress;
  final String tokenId;
}

/// Pre-flight simulation result for an outgoing transaction.
class SimulationResult {
  const SimulationResult({
    required this.willRevert,
    required this.revertReason,
    required this.gasUnits,
    required this.gasCostEth,
    required this.gasCostUsd,
    required this.assetChanges,
  });

  final bool willRevert;
  final String revertReason; // empty when willRevert == false
  final int gasUnits;
  final String gasCostEth; // "0.00012345"
  final String gasCostUsd; // "$0.42" or empty
  final List<SimulatedAssetChange> assetChanges;
}

/// Calls SimulateSend on the backend. `tokenAddress` empty = native ETH.
abstract interface class SimulationRepository {
  Future<SimulationResult> simulate({
    required String to,
    required String amount,
    String tokenAddress = '',
  });
}

class SimulationGrpcRepository implements SimulationRepository {
  const SimulationGrpcRepository();

  @override
  Future<SimulationResult> simulate({
    required String to,
    required String amount,
    String tokenAddress = '',
  }) async {
    final request = SimulateSendRequest()
      ..to = to
      ..amount = amount
      ..tokenAddress = tokenAddress;
    final response = await GrpcClient.instance.stub.simulateSend(request);
    return SimulationResult(
      willRevert: response.willRevert,
      revertReason: response.revertReason,
      gasUnits: response.gasUnits.toInt(),
      gasCostEth: response.gasCostEth,
      gasCostUsd: response.gasCostUsd,
      assetChanges: response.assetChanges
          .map(
            (c) => SimulatedAssetChange(
              kind: c.kind,
              changeType: c.changeType,
              from: c.from,
              to: c.to,
              amount: c.amount,
              symbol: c.symbol,
              name: c.name,
              decimals: c.decimals,
              contractAddress: c.contractAddress,
              tokenId: c.tokenId,
            ),
          )
          .toList(),
    );
  }
}
