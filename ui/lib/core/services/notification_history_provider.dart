import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/core/wallet_events/data/wallet_events_grpc_repository.dart';
import 'package:nox/core/wallet_events/wallet_events_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wallet_proto/wallet/service.pb.dart' as $wallet;

part 'notification_history_provider.g.dart';

/// Accumulates [WalletEvent]s from [walletEventsProvider]. On first build
/// the list is hydrated from the backend `ListNotifications` RPC so panel
/// content survives app restarts; subsequent live events from the
/// `WatchEvents` stream are prepended on top. Capped at 200 most recent
/// (matches the server-side prune budget).
///
/// Each event carries its server-side `id` and `isRead` flag — the read
/// state lives on the row itself rather than a single "last-seen" pointer,
/// which means scrolled-past unread entries don't get masked when newer
/// events arrive in the meantime.
@Riverpod(keepAlive: true)
class NotificationHistory extends _$NotificationHistory {
  static const _maxItems = 200;

  @override
  List<WalletEvent> build() {
    // Subscribe to the live stream right away — events that arrive before
    // the backfill resolves still get captured (they're newer, so they
    // belong at the front of the merged list anyway).
    ref.listen(walletEventsProvider, (_, next) {
      next.whenData((event) {
        // Live events may share an ID with one we already have if the
        // server replays after a reconnect; dedupe by ID, otherwise
        // prepend.
        final existing = state;
        final dedup = event.id.isEmpty
            ? existing
            : existing.where((e) => e.id != event.id).toList(growable: false);
        state = [event, ...dedup].take(_maxItems).toList();
      });
    });

    // Fire the backfill in the background; the provider returns an empty
    // list synchronously so the UI doesn't block.
    unawaited(_hydrate());

    return const [];
  }

  /// Loads recent notifications from the backend. Called once on first
  /// build. Errors are swallowed (logging-only would need a logger
  /// dependency; an empty hydration is non-fatal — fresh events still
  /// stream in via `WatchEvents`).
  Future<void> _hydrate() async {
    try {
      final response = await GrpcClient.instance.stub.listNotifications(
        $wallet.ListNotificationsRequest()..limit = _maxItems,
      );
      final past = response.items.map(walletEventFromEnvelope).toList(growable: false);
      // Merge: keep any live events that arrived during the round-trip
      // at the head, append historical ones below, dedupe by id (live
      // and persisted now share IDs).
      final liveIds = state.where((e) => e.id.isNotEmpty).map((e) => e.id).toSet();
      final pastFiltered = past.where((e) => !liveIds.contains(e.id));
      state = <WalletEvent>[...state, ...pastFiltered].take(_maxItems).toList();
    } on Object catch (_) {
      // Backfill is best-effort; live stream will populate the panel.
    }
  }

  /// Marks a single notification as read on the server, then patches the
  /// in-memory list. Idempotent — re-marking a read row is a no-op both
  /// locally and on the backend.
  Future<void> markRead(String id) async {
    if (id.isEmpty) return;
    if (!state.any((e) => e.id == id && !e.isRead)) return;

    try {
      await GrpcClient.instance.stub.markNotificationRead(
        $wallet.MarkNotificationReadRequest()..id = id,
      );
    } on Object catch (_) {
      // Even if the server didn't ack, flip locally — the next
      // ListNotifications hydration will re-sync if needed. Better UX
      // than leaving the dot stuck on screen.
    }

    state = [
      for (final e in state)
        if (e.id == id) e.copyWith(isRead: true) else e,
    ];
  }

  /// Marks every event as read in one round-trip.
  Future<void> markAllRead() async {
    if (!state.any((e) => !e.isRead)) return;

    try {
      await GrpcClient.instance.stub.markAllNotificationsRead(
        $wallet.MarkAllNotificationsReadRequest(),
      );
    } on Object catch (_) {
      // Same fallback rationale as markRead.
    }

    state = [for (final e in state) e.copyWith(isRead: true)];
  }

  /// Wipes both server-side history and the local cache. Used by the
  /// "Clear all" action in the notification center (UI confirms first).
  Future<void> clearAll() async {
    try {
      await GrpcClient.instance.stub.clearNotifications(
        $wallet.ClearNotificationsRequest(),
      );
    } on Object catch (_) {}

    state = const [];
  }

  /// Local-only reset used by sign-out / wallet-switch flows where the
  /// server-side history shouldn't be touched.
  void clear() {
    state = const [];
  }
}

/// Convenience: derived count of unread events. Capped at 99 for display.
@Riverpod(keepAlive: true)
int unreadNotifications(Ref ref) {
  final events = ref.watch(notificationHistoryProvider);
  var n = 0;
  for (final e in events) {
    if (!e.isRead) n++;
    if (n >= 99) return 99;
  }
  return n;
}
