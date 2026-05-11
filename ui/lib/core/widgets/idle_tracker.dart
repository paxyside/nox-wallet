import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/state/auto_lock_provider.dart';

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

  void _evaluateLock() {
    final timeout = ref.read(autoLockSettingProvider).duration;
    if (timeout == null) return;
    final last = ref.read(lastActivityProvider);
    if (DateTime.now().difference(last) < timeout) return;
    if (!ref.read(isUnlockedProvider)) return;
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
