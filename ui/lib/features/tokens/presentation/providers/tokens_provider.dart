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

// ── Visibility filter ─────────────────────────────────────────────────────────
//
// The Tokens screen lets the user flip between three views. Default is
// `visible` because that's the only state most users will ever need; the
// other two exist as an escape hatch when something was hidden and the
// user wants it back without remembering the contract address.

enum TokenVisibility { visible, hidden, all }

@riverpod
class TokensVisibilityFilter extends _$TokensVisibilityFilter {
  @override
  TokenVisibility build() => TokenVisibility.visible;

  void select(TokenVisibility v) {
    if (v == state) return;
    state = v;
  }
}

// ── Filtered + sorted list ────────────────────────────────────────────────────

@riverpod
List<WatchedToken> filteredTokens(Ref ref) {
  final tokens = ref.watch(tokensNotifierProvider).valueOrNull ?? [];
  final query = ref.watch(tokensSearchProvider).toLowerCase().trim();
  final sort = ref.watch(tokensSortProvider);
  final visibility = ref.watch(tokensVisibilityFilterProvider);

  // Step 1 — visibility filter.
  var result = switch (visibility) {
    TokenVisibility.visible => tokens.where((t) => !t.isHidden),
    TokenVisibility.hidden => tokens.where((t) => t.isHidden),
    TokenVisibility.all => tokens,
  };

  // Step 2 — text search.
  if (query.isNotEmpty) {
    result = result.where(
      (t) =>
          t.symbol.toLowerCase().contains(query) ||
          t.name.toLowerCase().contains(query) ||
          t.address.toLowerCase().contains(query),
    );
  }

  // Step 3 — sort. Pinned always first, then by chosen field.
  return result.toList()..sort((a, b) {
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
//
// Computed across VISIBLE tokens only — hidden tokens shouldn't pollute the
// dashboard total even though they're now part of `tokensNotifierProvider`'s
// raw list. Dashboard widgets reading this should still see "real money".

@riverpod
String totalPortfolioValue(Ref ref) {
  final tokens = ref.watch(tokensNotifierProvider).valueOrNull ?? [];
  if (tokens.isEmpty) return '';
  var total = 0.0;
  for (final t in tokens) {
    if (t.isHidden) continue;
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

  /// Hide / unhide. Hidden tokens stay in storage AND in the in-memory
  /// list — only the UI's `tokensVisibilityFilterProvider` decides what
  /// to show. Flipping the flag in-place means the row visibly "moves"
  /// between Visible / Hidden filter views without a network round-trip.
  Future<void> hide(String id, {required bool hidden}) async {
    final previous = state.valueOrNull ?? [];
    // Optimistic: flip the flag on the matching entry. The backend
    // persists `is_hidden=hidden` and replies; on failure we roll back.
    state = AsyncData([
      for (final t in previous) t.id == id ? t.copyWith(isHidden: hidden) : t,
    ]);
    try {
      await ref.read(tokenRepositoryProvider).hide(id, hidden: hidden);
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
