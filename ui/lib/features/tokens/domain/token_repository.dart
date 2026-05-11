import 'package:nox/features/tokens/domain/watched_token.dart';

abstract interface class TokenRepository {
  Future<List<WatchedToken>> listWithBalances();
  Future<WatchedToken> add(String contractAddress);
  Future<void> remove(String id);
  Future<void> pin(String id, {required bool pinned});
  Future<void> hide(String id, {required bool hidden});
}
