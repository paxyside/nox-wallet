// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationsHash() => r'cee6bf981c94c5a37c94704f19afb37344c40aa3';

/// Convenience: derived count of unread events. Capped at 99 for display.
///
/// Copied from [unreadNotifications].
@ProviderFor(unreadNotifications)
final unreadNotificationsProvider = Provider<int>.internal(
  unreadNotifications,
  name: r'unreadNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsRef = ProviderRef<int>;
String _$notificationHistoryHash() => r'6a84fb9b04d32decf13ad836994b624ca80b6f79';

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
///
/// Copied from [NotificationHistory].
@ProviderFor(NotificationHistory)
final notificationHistoryProvider =
    NotifierProvider<NotificationHistory, List<WalletEvent>>.internal(
      NotificationHistory.new,
      name: r'notificationHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationHistory = Notifier<List<WalletEvent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
