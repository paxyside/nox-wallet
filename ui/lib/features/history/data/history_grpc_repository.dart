import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/history/domain/history_repository.dart';
import 'package:wallet_proto/wallet/common/common.pb.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

class HistoryGrpcRepository implements HistoryRepository {
  const HistoryGrpcRepository({required this.walletAddress});

  final String walletAddress;

  @override
  Future<HistoryPage> getHistory({
    String cursor = '',
    int limit = 20,
  }) async {
    final pageParams = PageParams()
      ..limit = limit
      ..cursor = cursor;

    final request = GetHistoryRequest()
      ..address = walletAddress
      ..page = pageParams;

    final response = await GrpcClient.instance.stub.getHistory(request);

    final items = response.items.map((item) {
      final dt = item.hasBlockTime()
          ? DateTime.fromMillisecondsSinceEpoch(
              item.blockTime.seconds.toInt() * 1000,
            )
          : DateTime.fromMillisecondsSinceEpoch(0);

      return Transaction(
        txHash: item.txHash,
        from: item.from,
        to: item.to,
        asset: item.asset,
        value: item.value,
        category: item.category,
        blockNum: item.blockNum.toInt(),
        blockTime: dt,
        walletAddress: walletAddress,
        gasFeeEth: item.gasFeeEth,
        gasFeeUsd: item.gasFeeUsd,
        valueUsd: item.valueUsd,
        isSwap: item.isSwap,
        tokenInSym: item.tokenInSym,
        tokenInValue: item.tokenInValue,
        tokenOutSym: item.tokenOutSym,
        tokenOutValue: item.tokenOutValue,
      );
    }).toList();

    return HistoryPage(
      items: items,
      nextCursor: response.pageInfo.nextCursor,
      hasMore: response.pageInfo.hasMore,
      totalCount: response.pageInfo.totalCount,
    );
  }
}
