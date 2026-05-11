import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/tokens/domain/token_repository.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:wallet_proto/wallet/service.pb.dart';
import 'package:wallet_proto/wallet/token/token.pb.dart' as $tokenpb;

class TokenGrpcRepository implements TokenRepository {
  const TokenGrpcRepository();

  @override
  Future<List<WatchedToken>> listWithBalances() async {
    final response = await GrpcClient.instance.stub.listTokensWithBalances(
      ListTokensWithBalancesRequest(),
    );
    return response.tokens.map(_fromProto).toList();
  }

  @override
  Future<WatchedToken> add(String contractAddress) async {
    final request = AddTokenRequest()..address = contractAddress;
    final response = await GrpcClient.instance.stub.addToken(request);
    return WatchedToken(
      id: response.token.id,
      address: response.token.address,
      symbol: response.token.symbol,
      name: response.token.name,
      decimals: response.token.decimals,
      balance: '',
      isPinned: response.token.isPinned,
    );
  }

  @override
  Future<void> remove(String id) async {
    await GrpcClient.instance.stub.removeToken(RemoveTokenRequest()..id = id);
  }

  @override
  Future<void> pin(String id, {required bool pinned}) async {
    await GrpcClient.instance.stub.pinToken(
      PinTokenRequest()
        ..id = id
        ..pinned = pinned,
    );
  }

  @override
  Future<void> hide(String id, {required bool hidden}) async {
    await GrpcClient.instance.stub.hideToken(
      HideTokenRequest()
        ..id = id
        ..hidden = hidden,
    );
  }

  WatchedToken _fromProto($tokenpb.WatchedTokenWithBalance proto) {
    final m = proto.hasMarket() ? proto.market : null;
    return WatchedToken(
      id: proto.token.id,
      address: proto.token.address,
      symbol: proto.token.symbol,
      name: proto.token.name,
      decimals: proto.token.decimals,
      balance: proto.balance,
      isPinned: proto.token.isPinned,
      isHidden: proto.token.isHidden,
      balanceUsd: proto.balanceUsd,
      priceUsd: m?.priceUsd ?? '',
      change24hPct: m?.change24hPct ?? '',
      changePositive: m?.changePositive ?? true,
      sparkline7d: m?.sparkline7d.toList() ?? const [],
      sparkline30d: m?.sparkline30d.toList() ?? const [],
    );
  }
}
