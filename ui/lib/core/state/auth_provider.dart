import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// True after the user successfully authenticates on startup.
@Riverpod(keepAlive: true)
class IsUnlocked extends _$IsUnlocked {
  @override
  bool build() => false;

  void unlock() {
    if (state) return;
    state = true;
  }

  void lock() {
    if (!state) return;
    state = false;
    // A fresh lock should auto-prompt Touch ID once on the next
    // LockScreen mount. Subsequent re-mounts (e.g. window resize from
    // mini → full while still locked) consume the flag and skip the
    // prompt — fixes the "Touch ID asked every 30 s" loop.
    ref.read(lockPromptPendingProvider.notifier).schedule();
  }
}

/// One-shot gate that controls whether the next LockScreen mount may
/// auto-prompt Touch ID.
///
/// - `build()` defaults to `true` so the **very first** launch greets the
///   user with a Touch ID prompt automatically.
/// - `IsUnlocked.lock()` flips it back to `true` whenever the wallet
///   re-locks (idle timeout, sidebar "Lock" button) — so a fresh lock
///   re-prompts once.
/// - LockScreen consumes (sets `false`) when it triggers the prompt.
///
/// This decouples the prompt from widget-mount events: macOS window
/// re-shows / mini ↔ full transitions remount LockScreen but don't
/// re-prompt because the flag is already consumed.
@Riverpod(keepAlive: true)
class LockPromptPending extends _$LockPromptPending {
  @override
  bool build() => true;

  /// Read-and-clear. Returns whether the caller should auto-prompt.
  bool consume() {
    if (!state) return false;
    state = false;
    return true;
  }

  /// Re-arm so the next mount will prompt. Idempotent.
  void schedule() {
    if (state) return;
    state = true;
  }
}

/// True while the app is displaying the compact menu-bar mini widget.
@riverpod
class IsMiniMode extends _$IsMiniMode {
  @override
  bool build() => false;

  void enter() {
    if (state) return;
    state = true;
  }

  void exit() {
    if (!state) return;
    state = false;
  }
}
