// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationSettingsCtrlHash() => r'81c1d219319c50e1852b20adb0dbac510390883a';

/// User-tunable notification preferences mirrored from the SQLite
/// singleton row. The provider hydrates on first read via
/// `GetNotificationSettings` and writes through `UpdateNotificationSettings`
/// — the server echoes the persisted values back so no extra round-trip
/// is needed after a save.
///
/// Copied from [NotificationSettingsCtrl].
@ProviderFor(NotificationSettingsCtrl)
final notificationSettingsCtrlProvider =
    AsyncNotifierProvider<NotificationSettingsCtrl, NotificationSettings>.internal(
      NotificationSettingsCtrl.new,
      name: r'notificationSettingsCtrlProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSettingsCtrlHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSettingsCtrl = AsyncNotifier<NotificationSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
