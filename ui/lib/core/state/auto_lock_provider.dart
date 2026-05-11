import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_lock_provider.g.dart';

/// Available auto-lock idle timeouts. `none` disables auto-lock.
enum AutoLockTimeout { none, oneMinute, fiveMinutes, fifteenMinutes, oneHour }

extension AutoLockTimeoutDuration on AutoLockTimeout {
  Duration? get duration => switch (this) {
    AutoLockTimeout.none => null,
    AutoLockTimeout.oneMinute => const Duration(minutes: 1),
    AutoLockTimeout.fiveMinutes => const Duration(minutes: 5),
    AutoLockTimeout.fifteenMinutes => const Duration(minutes: 15),
    AutoLockTimeout.oneHour => const Duration(hours: 1),
  };

  String get label => switch (this) {
    AutoLockTimeout.none => 'Never',
    AutoLockTimeout.oneMinute => '1 minute',
    AutoLockTimeout.fiveMinutes => '5 minutes',
    AutoLockTimeout.fifteenMinutes => '15 minutes',
    AutoLockTimeout.oneHour => '1 hour',
  };
}

/// User's preferred auto-lock idle timeout. Stored in-memory only — persists
/// for the app's lifetime, defaults to 5 minutes.
@Riverpod(keepAlive: true)
class AutoLockSetting extends _$AutoLockSetting {
  @override
  AutoLockTimeout build() => AutoLockTimeout.fiveMinutes;

  void setTimeout(AutoLockTimeout timeout) {
    if (timeout == state) return;
    state = timeout;
  }
}

/// Tracks the wall-clock time of the last user activity (pointer/key event).
///
/// Updated by a single global gesture detector wrapping the app shell.
/// The idle-tracker widget evaluates whether to lock based on this value.
@Riverpod(keepAlive: true)
class LastActivity extends _$LastActivity {
  @override
  DateTime build() => DateTime.now();

  void touch() {
    state = DateTime.now();
  }
}

/// Returns `true` when the configured auto-lock timeout has elapsed since the
/// last recorded user activity.
@immutable
class AutoLockEvaluation {
  const AutoLockEvaluation({required this.shouldLock});
  final bool shouldLock;
}
