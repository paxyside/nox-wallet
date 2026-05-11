import 'package:flutter/foundation.dart';
import 'package:nox/core/network/grpc_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wallet_proto/wallet/service.pb.dart' as $wallet;

part 'notification_settings_provider.g.dart';

/// Pure-Dart mirror of `wallet.NotificationSettings`. Kept separate from
/// the proto type so widgets and providers don't import generated code
/// directly — same pattern as `WalletEvent` vs `pb.WalletEvent`.
@immutable
class NotificationSettings {
  const NotificationSettings({
    required this.playSound,
    required this.macosToasts,
    required this.autoMarkRead,
    required this.autoDeleteDays,
    required this.muteSystemAlerts,
  });

  /// Conservative defaults shown when the backend hasn't responded yet.
  /// They match the migration seed so a first-paint with defaults
  /// reflects what the server will eventually return.
  const NotificationSettings.defaults()
    : playSound = true,
      macosToasts = true,
      autoMarkRead = false,
      autoDeleteDays = 0,
      muteSystemAlerts = false;

  final bool playSound;
  final bool macosToasts;
  final bool autoMarkRead;

  /// 0 disables auto-delete entirely.
  final int autoDeleteDays;
  final bool muteSystemAlerts;

  NotificationSettings copyWith({
    bool? playSound,
    bool? macosToasts,
    bool? autoMarkRead,
    int? autoDeleteDays,
    bool? muteSystemAlerts,
  }) => NotificationSettings(
    playSound: playSound ?? this.playSound,
    macosToasts: macosToasts ?? this.macosToasts,
    autoMarkRead: autoMarkRead ?? this.autoMarkRead,
    autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
    muteSystemAlerts: muteSystemAlerts ?? this.muteSystemAlerts,
  );
}

NotificationSettings _fromProto($wallet.NotificationSettings p) => NotificationSettings(
  playSound: p.playSound,
  macosToasts: p.macosToasts,
  autoMarkRead: p.autoMarkRead,
  autoDeleteDays: p.autoDeleteDays,
  muteSystemAlerts: p.muteSystemAlerts,
);

$wallet.NotificationSettings _toProto(NotificationSettings s) => $wallet.NotificationSettings()
  ..playSound = s.playSound
  ..macosToasts = s.macosToasts
  ..autoMarkRead = s.autoMarkRead
  ..autoDeleteDays = s.autoDeleteDays
  ..muteSystemAlerts = s.muteSystemAlerts;

/// User-tunable notification preferences mirrored from the SQLite
/// singleton row. The provider hydrates on first read via
/// `GetNotificationSettings` and writes through `UpdateNotificationSettings`
/// — the server echoes the persisted values back so no extra round-trip
/// is needed after a save.
@Riverpod(keepAlive: true)
class NotificationSettingsCtrl extends _$NotificationSettingsCtrl {
  @override
  Future<NotificationSettings> build() async {
    try {
      final response = await GrpcClient.instance.stub.getNotificationSettings(
        $wallet.GetNotificationSettingsRequest(),
      );
      return _fromProto(response.settings);
    } on Object catch (_) {
      // Backend unreachable on first launch — surface defaults rather
      // than blocking the UI on a network error.
      return const NotificationSettings.defaults();
    }
  }

  Future<void> save(NotificationSettings next) async {
    // Optimistic UI: flip immediately, roll back if the server rejects.
    final previous = state.valueOrNull;
    state = AsyncData(next);

    try {
      final response = await GrpcClient.instance.stub.updateNotificationSettings(
        $wallet.UpdateNotificationSettingsRequest()..settings = _toProto(next),
      );
      state = AsyncData(_fromProto(response.settings));
    } on Object catch (_) {
      if (previous != null) state = AsyncData(previous);
    }
  }
}
