import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nox/core/services/notification_copy.dart';
import 'package:nox/core/services/notification_settings_provider.dart';
import 'package:nox/core/services/sound_service.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';

/// Wrapper around `flutter_local_notifications` for wallet-specific OS
/// toasts. Replaced the previous `local_notifier` integration which sat
/// on top of the macOS-11-deprecated `NSUserNotification` API and now
/// emits a wall of build warnings; this plugin uses the modern
/// `UNUserNotificationCenter` framework on Darwin.
///
/// One event = at most one OS toast. The previous setup fanned out 2-4
/// notifications per user-action (a token Send produced "TOKEN sent" +
/// "ETH sent (gas burn)"; a Swap produced 3 separate events). The
/// canonical TransactionEvent now collapses them into one.
///
/// Delivery is gated by [NotificationSettings] passed per-call: the
/// caller (the watcher listener in `main.dart`) holds the active
/// settings via Riverpod and threads them through, which keeps this
/// service stateless and trivially testable.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Sequential id counter for `_plugin.show(id, ...)`. The plugin
  /// requires a 32-bit signed int per delivery; we don't dedupe by
  /// content (kept the same loose semantics as the previous local_
  /// notifier integration), so we just monotonically advance.
  int _nextId = 0;

  Future<void> init() async {
    // macOS / iOS: provide initialization settings. We don't request
    // permissions at init time — UNUserNotificationCenter prompts the
    // user on the first .show() automatically, which feels more natural
    // than an unsolicited dialog at startup. If the user declines, the
    // plugin silently drops subsequent shows.
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const init = InitializationSettings(macOS: darwin, iOS: darwin);

    await _plugin.initialize(init);

    // Politely ask once on first launch. Subsequent calls are no-ops
    // (system remembers the answer). This warms the permission state
    // so the first wallet event can fire without a perceived delay.
    // We don't ask for `sound` because we never use the toast's sound
    // channel — the in-app NSSound chime via SoundService is our
    // single source of audio.
    final macImpl = _plugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    await macImpl?.requestPermissions(alert: true, badge: true, sound: false);
  }

  /// Surfaces the OS toast and/or in-app chime as the user's settings
  /// allow. Returns silently when both delivery channels are off or
  /// the event has no human-readable copy.
  ///
  /// Audio is never piped through the toast itself (`presentSound` is
  /// always false) — the chime path via [SoundService] is our single
  /// source of audio. See `sound_service.dart` for rationale.
  ///
  /// Skipped entirely when:
  ///   - `macosToasts` is off **and** `playSound` is off (nothing to do);
  ///   - the event is a system alert (gas / low balance) and
  ///     `muteSystemAlerts` is on;
  ///   - the copy resolver returns null (no human-readable spec for
  ///     this kind — usually an unmapped legacy event).
  Future<void> notify(
    WalletEvent event, {
    required NotificationSettings settings,
  }) async {
    if (settings.muteSystemAlerts && _isSystemAlert(event)) return;
    if (!settings.macosToasts && !settings.playSound) return;

    final spec = NotificationCopy.forEvent(event);
    if (spec == null) return;

    if (settings.playSound) {
      await SoundService.playChime();
    }

    if (!settings.macosToasts) return;

    final details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        // Always silent — the chime above is the sound channel.
        presentSound: false,
        // Pass the copy spec id as a thread identifier so macOS visually
        // groups successive entries of the same kind (e.g. multiple
        // receives) in Notification Center.
        threadIdentifier: spec.id,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
        threadIdentifier: spec.id,
      ),
    );

    await _plugin.show(_nextId++, spec.title, spec.body, details);
  }

  static bool _isSystemAlert(WalletEvent event) =>
      event.kind == WalletEventKind.gasAlert || event.kind == WalletEventKind.lowBalance;
}
