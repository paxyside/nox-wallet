import 'package:flutter/services.dart';

/// Plays short system chimes via the macOS `NSSound` API. Wired from
/// the wallet-event listener in `main.dart` whenever a notification
/// arrives and the user has the "Sound" toggle on in the notification
/// center settings.
///
/// We picked this over riding on the macOS toast sound (`presentSound`
/// on `DarwinNotificationDetails`) for two reasons:
///   1. Toast sound only plays when the toast itself is rendered;
///      macOS suppresses toasts entirely when the app is focused, so
///      a user staring at the wallet during a swap heard nothing.
///   2. Decoupling the audio from the toast lets the user keep visual
///      toasts off (e.g. presenting a screen) while still hearing
///      that something happened.
abstract final class SoundService {
  static const _channel = MethodChannel('nox/sound');

  /// Plays the named macOS system sound. Names are any NSSound system
  /// name: Glass, Ping, Pop, Tink, Hero, Funk, Frog, Basso, Blow,
  /// Bottle, Morse, Purr, Sosumi, Submarine. Defaults to "Glass" — a
  /// short, distinct ping that doesn't collide with browser / Slack
  /// chimes. Errors are swallowed: a failed audio call shouldn't
  /// surface in the UI.
  static Future<void> playChime({String name = 'Glass'}) async {
    try {
      await _channel.invokeMethod<void>('playChime', {'name': name});
    } on PlatformException {
      // Plugin missing on non-macOS hosts (none today, but cheap to
      // future-proof) or method handler wasn't registered yet.
    }
  }
}
