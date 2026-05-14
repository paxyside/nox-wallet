import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/state/auto_lock_provider.dart';
import 'package:window_manager/window_manager.dart';

/// Wraps [child] in a transparent input-tracking layer that:
///   1. Records the wall-clock time of every pointer / key event into
///      `lastActivityProvider`.
///   2. Periodically checks (every 10 s) whether the user has been idle longer
///      than the configured `autoLockSettingProvider`. If so, locks the wallet.
///
/// Pointer events are captured via a translucent [Listener] at the root.
/// Keyboard activity is tracked via [HardwareKeyboard]'s global handler —
/// **not** via a [Focus] wrapper, because wrapping the entire app tree in a
/// `Focus` widget breaks the focus chain of text fields (causing
/// `KeyDownEvent dispatched but key already pressed` warnings on the second
/// stroke after a focus change).
///
/// Place once at the very top of the unlocked widget tree.
class IdleTracker extends ConsumerStatefulWidget {
  const IdleTracker({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<IdleTracker> createState() => _IdleTrackerState();
}

class _IdleTrackerState extends ConsumerState<IdleTracker> {
  static const _evaluateEvery = Duration(seconds: 10);

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(_evaluateEvery, (_) => _evaluateLock());
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _ticker?.cancel();
    super.dispose();
  }

  void _touch() {
    ref.read(lastActivityProvider.notifier).touch();
  }

  /// Pointer event handler — signature matches `Listener`'s callbacks.
  void _onPointer([Object? _]) => _touch();

  /// Global hardware-keyboard handler. Returning `false` lets the rest of the
  /// framework process the event normally (text fields, shortcuts, etc.).
  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) _touch();
    return false;
  }

  Future<void> _evaluateLock() async {
    if (!ref.read(isUnlockedProvider)) return;

    final timeout = ref.read(autoLockSettingProvider).duration;
    if (timeout == null) return;

    // Auto-lock should only count time the wallet is actually on screen.
    // While focus is on another macOS app, no-one can see Nox anyway —
    // counting that as idle made the wallet lock every time the user
    // glanced at Slack for >5 min, then asked for Touch ID on return.
    // We refresh `lastActivity` each tick while unfocused so the idle
    // clock effectively "pauses" until the user comes back.
    final focused = await windowManager.isFocused();
    if (!focused) {
      _touch();
      return;
    }

    final last = ref.read(lastActivityProvider);
    if (DateTime.now().difference(last) < timeout) return;
    ref.read(isUnlockedProvider.notifier).lock();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointer,
      onPointerMove: _onPointer,
      onPointerSignal: _onPointer,
      child: widget.child,
    );
  }
}
