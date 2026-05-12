import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nox/core/state/wallet_address_provider.dart';
import 'package:nox/features/history/data/history_grpc_repository.dart';
import 'package:nox/features/history/domain/history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_provider.g.dart';

// ---------------------------------------------------------------------------
// Filter state
// ---------------------------------------------------------------------------

/// Direction filter for the history list.
enum TxDirection { all, sent, received, swaps }

/// Date range filter.
enum DateRange { all, d7, d30, d90 }

extension DateRangeLabel on DateRange {
  String get label => switch (this) {
    DateRange.all => 'All time',
    DateRange.d7 => 'Last 7 days',
    DateRange.d30 => 'Last 30 days',
    DateRange.d90 => 'Last 90 days',
  };
  int? get days => switch (this) {
    DateRange.all => null,
    DateRange.d7 => 7,
    DateRange.d30 => 30,
    DateRange.d90 => 90,
  };
}

/// Immutable filter applied to the history list.
@immutable
class HistoryFilter {
  const HistoryFilter({
    this.direction = TxDirection.all,
    this.asset = '',
    this.dateRange = DateRange.all,
    this.query = '',
  });

  final TxDirection direction;
  final String asset;
  final DateRange dateRange;

  /// Free-text search — matched against tx hash, from/to addresses, and asset
  /// symbol. Empty string means no search filter applied.
  final String query;

  HistoryFilter copyWith({
    TxDirection? direction,
    String? asset,
    DateRange? dateRange,
    String? query,
  }) => HistoryFilter(
    direction: direction ?? this.direction,
    asset: asset ?? this.asset,
    dateRange: dateRange ?? this.dateRange,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryFilter &&
          other.direction == direction &&
          other.asset == asset &&
          other.dateRange == dateRange &&
          other.query == query;

  @override
  int get hashCode => Object.hash(direction, asset, dateRange, query);
}

// ---------------------------------------------------------------------------
// Page state
// ---------------------------------------------------------------------------

/// The accumulated state for the history list (all loaded pages combined).
class HistoryState {
  const HistoryState({
    required this.allItems,
    this.nextCursor = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.totalCount = 0,
  });

  /// Raw items as returned by the server (before any client-side filtering).
  final List<Transaction> allItems;
  final String nextCursor;
  final bool hasMore;

  /// True while a "load more" request is in flight.
  final bool isLoadingMore;

  /// Total number of transactions in the DB (across all pages).
  final int totalCount;

  /// Unique non-ETH asset symbols seen in the loaded transactions.
  /// Used to build the asset filter chips dynamically.
  /// Only symbols with 2–10 ASCII-uppercase characters are included
  /// to filter out garbage / spam look-alikes.
  List<String> get assets {
    final seen = <String>{};
    final result = <String>[];
    for (final tx in allItems) {
      final sym = tx.asset.toUpperCase();
      if (sym.length < 2 || sym.length > 10) continue;
      if (sym == 'ETH') continue;
      if (!RegExp(r'^[A-Z0-9]+$').hasMatch(sym)) continue;
      if (seen.add(sym)) result.add(sym);
    }
    return result;
  }

  /// Returns items after applying all client-side filters.
  List<Transaction> filtered(HistoryFilter f) {
    var items = allItems;

    // Date filter.
    final days = f.dateRange.days;
    if (days != null) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      items = items.where((t) => t.blockTime.isAfter(cutoff)).toList();
    }

    // Asset filter: exact symbol match (case-insensitive).
    if (f.asset.isNotEmpty) {
      final upper = f.asset.toUpperCase();
      items = items.where((t) => t.asset.toUpperCase() == upper).toList();
    }

    // Free-text search: matches hash, from, to, asset symbol — substring,
    // case-insensitive. Lets the user paste a full hash or just the last
    // few hex chars and find the row.
    if (f.query.isNotEmpty) {
      final q = f.query.toLowerCase();
      items = items.where((t) {
        return t.txHash.toLowerCase().contains(q) ||
            t.from.toLowerCase().contains(q) ||
            t.to.toLowerCase().contains(q) ||
            t.asset.toLowerCase().contains(q) ||
            t.tokenInSym.toLowerCase().contains(q) ||
            t.tokenOutSym.toLowerCase().contains(q);
      }).toList();
    }

    // Direction filter.
    return switch (f.direction) {
      TxDirection.all => items,
      TxDirection.sent => items.where((t) => !t.isIncoming && !t.isSwap).toList(),
      TxDirection.received => items.where((t) => t.isIncoming && !t.isSwap).toList(),
      TxDirection.swaps => items.where((t) => t.isSwap).toList(),
    };
  }

  HistoryState copyWith({
    List<Transaction>? allItems,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
  }) => HistoryState(
    allItems: allItems ?? this.allItems,
    nextCursor: nextCursor ?? this.nextCursor,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    totalCount: totalCount ?? this.totalCount,
  );
}

// ---------------------------------------------------------------------------
// Filter notifier
// ---------------------------------------------------------------------------

@riverpod
class HistoryFilterNotifier extends _$HistoryFilterNotifier {
  @override
  HistoryFilter build() => const HistoryFilter();

  void setDirection(TxDirection direction) => state = state.copyWith(direction: direction);

  void setAsset(String asset) => state = state.copyWith(asset: asset);
  void setDateRange(DateRange range) => state = state.copyWith(dateRange: range);
  void setQuery(String query) => state = state.copyWith(query: query.trim());
  void reset() => state = const HistoryFilter();
}

// ---------------------------------------------------------------------------
// History notifier
// ---------------------------------------------------------------------------

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  HistoryRepository? _repo;
  String _walletAddress = '';

  // Hard cap on auto-paginated fetches per wallet load. Keeps a runaway
  // backend (loops returning hasMore=true forever) from saturating gRPC.
  // 30 pages × 20 raw legs ≈ 600 entries — far past any realistic wallet's
  // recent history.
  static const _maxAutoPages = 30;

  @override
  Future<HistoryState> build() async {
    // Filters are client-side — no need to re-fetch on filter change.
    // Just resolve the wallet address and load the first page, then eagerly
    // continue loading subsequent pages in the background. Without the
    // background drain we'd only have the first 18-20 merged entries client-
    // side and the pagination footer would lie about totals (server returns
    // a real count, but the visible list would just be page 1's slice).
    _walletAddress = await ref.watch(walletAddressProvider.future).catchError((_) => '');
    _repo = HistoryGrpcRepository(walletAddress: _walletAddress);
    final firstPage = await _fetchPage(cursor: '');

    // Kick off background drain *after* the build's Future resolves and
    // Riverpod has had a chance to assign `state = AsyncData(firstPage)`.
    // Scheduling via Future.microtask runs too early — the state would
    // still be null and the drain would no-op. A regular Future task hits
    // the next event-loop turn, after assignment.
    if (firstPage.hasMore) {
      // Fire-and-forget: drain runs in the background and updates `state`
      // incrementally. We deliberately don't await it so the first page
      // renders immediately.
      unawaited(Future(() => _drainRemainingPages(firstPage)));
    }

    return firstPage;
  }

  Future<void> _drainRemainingPages(HistoryState initial) async {
    var current = initial;
    var loaded = 1;
    while (loaded < _maxAutoPages) {
      if (!current.hasMore) return;

      // Mark loading on the live state. Each fetch then replaces it with a
      // fresh page so the pagination footer grows in real time.
      state = AsyncData(current.copyWith(isLoadingMore: true));
      try {
        current = await _fetchPage(cursor: current.nextCursor, previous: current.allItems);
        state = AsyncData(current);
        loaded += 1;
      } on Object {
        // Stop draining on error — leave whatever has been loaded; user can
        // hit refresh to retry from scratch.
        state = AsyncData(current.copyWith(isLoadingMore: false));
        return;
      }
    }
  }

  Future<HistoryState> _fetchPage({
    required String cursor,
    List<Transaction> previous = const [],
  }) async {
    final repo = _repo ?? HistoryGrpcRepository(walletAddress: _walletAddress);
    final page = await repo.getHistory(cursor: cursor);
    return HistoryState(
      allItems: [...previous, ...page.items],
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      totalCount: page.totalCount > 0 ? page.totalCount : previous.length + page.items.length,
    );
  }

  /// Loads the next page and appends the results to the current list.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetchPage(cursor: current.nextCursor, previous: current.allItems);
      state = AsyncData(next.copyWith(isLoadingMore: false));
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Hard refresh — resets pagination and reloads from the beginning.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(cursor: ''));
  }
}
