import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/utils/formatters.dart';
import 'package:nox/features/tokens/data/token_grpc_repository.dart';
import 'package:nox/features/tokens/domain/token_repository.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tokens_provider.g.dart';

@riverpod
TokenRepository tokenRepository(Ref ref) => const TokenGrpcRepository();

// ── Sort options ──────────────────────────────────────────────────────────────

enum TokenSortField { name, balance, value, change }

@riverpod
class TokensSort extends _$TokensSort {
  @override
  TokenSortField build() => TokenSortField.value;

  void selectField(TokenSortField field) {
    if (field == state) return;
    state = field;
  }
}

// ── Search query ─────────────────────────────────────────────────────────────

@riverpod
class TokensSearch extends _$TokensSearch {
  @override
  String build() => '';

  void updateQuery(String query) {
    if (query == state) return;
    state = query;
  }

  void clear() => state = '';
}

// ── Filtered + sorted list ────────────────────────────────────────────────────

@riverpod
List<WatchedToken> filteredTokens(Ref ref) {
  final tokens = ref.watch(tokensNotifierProvider).valueOrNull ?? [];
  final query = ref.watch(tokensSearchProvider).toLowerCase().trim();
  final sort = ref.watch(tokensSortProvider);

  // Filter
  final result = query.isEmpty
      ? tokens
      : tokens
            .where(
              (t) =>
                  t.symbol.toLowerCase().contains(query) ||
                  t.name.toLowerCase().contains(query) ||
                  t.address.toLowerCase().contains(query),
            )
            .toList();

  // Sort: pinned always first, then by chosen field
  return List.of(result)..sort((a, b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    return switch (sort) {
      TokenSortField.name => a.symbol.compareTo(b.symbol),
      TokenSortField.balance => parseUsd(b.balance).compareTo(parseUsd(a.balance)),
      TokenSortField.value => parseUsd(b.balanceUsd).compareTo(parseUsd(a.balanceUsd)),
      TokenSortField.change => parseUsd(b.change24hPct).compareTo(parseUsd(a.change24hPct)),
    };
  });
}

// ── Total portfolio USD value ─────────────────────────────────────────────────

@riverpod
String totalPortfolioValue(Ref ref) {
  final tokens = ref.watch(tokensNotifierProvider).valueOrNull ?? [];
  if (tokens.isEmpty) return '';
  var total = 0.0;
  for (final t in tokens) {
    total += parseUsd(t.balanceUsd);
  }
  if (total == 0) return '';
  if (total >= 1000000) return '\$${(total / 1000000).toStringAsFixed(2)}M';
  if (total >= 1000) return '\$${(total / 1000).toStringAsFixed(2)}K';
  return '\$${total.toStringAsFixed(2)}';
}

// ── Main notifier ─────────────────────────────────────────────────────────────

// keepAlive: cached for the app's lifetime so navigating away and back to the
// dashboard doesn't trigger a re-fetch (which left the Portfolio chart empty
// for a frame because both `tokensNotifierProvider` and the price feed were
// loading at the same time).
@Riverpod(keepAlive: true)
class TokensNotifier extends _$TokensNotifier {
  @override
  Future<List<WatchedToken>> build() => ref.read(tokenRepositoryProvider).listWithBalances();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(tokenRepositoryProvider).listWithBalances());
  }

  Future<WatchedToken?> add(String contractAddress) async {
    final token = await ref.read(tokenRepositoryProvider).add(contractAddress);
    state = AsyncData([...?state.valueOrNull, token]);
    return token;
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncData(previous.where((t) => t.id != id).toList());
    try {
      await ref.read(tokenRepositoryProvider).remove(id);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// Hide / unhide. Hidden tokens stay in storage so the auto-seed dedup map
  /// still recognises them — just filtered out of the visible list.
  Future<void> hide(String id, {required bool hidden}) async {
    final previous = state.valueOrNull ?? [];
    // Optimistic: drop hidden token from the visible list immediately. The
    // backend keeps it stored.
    state = AsyncData(
      hidden ? previous.where((t) => t.id != id).toList() : previous, // unhide path: refresh below
    );
    try {
      await ref.read(tokenRepositoryProvider).hide(id, hidden: hidden);
      if (!hidden) await refresh(); // re-pull to bring the unhidden token back
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> togglePin(String id) async {
    final tokens = state.valueOrNull ?? [];
    final token = tokens.firstWhere((t) => t.id == id);
    final pinned = !token.isPinned;

    // Optimistic update
    state = AsyncData(tokens.map((t) => t.id == id ? t.copyWith(isPinned: pinned) : t).toList());

    try {
      await ref.read(tokenRepositoryProvider).pin(id, pinned: pinned);
    } catch (e) {
      state = AsyncData(tokens); // rollback
      rethrow;
    }
  }
}
