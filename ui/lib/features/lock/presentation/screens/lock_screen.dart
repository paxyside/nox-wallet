import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with SingleTickerProviderStateMixin {
  final _auth = LocalAuthentication();

  bool _loading = false;
  String? _error;
  bool _hasTouchId = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    unawaited(_init());
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      if (mounted) {
        setState(() {
          _hasTouchId =
              biometrics.contains(BiometricType.fingerprint) ||
              biometrics.contains(BiometricType.strong);
        });
      }
      // Auto-prompt only when the gate is armed (fresh lock or first
      // launch). Window-rebuild / mini↔full transitions also fire
      // initState and would otherwise re-trigger Touch ID; the gate
      // ensures one prompt per actual lock event.
      if (_hasTouchId && ref.read(lockPromptPendingProvider.notifier).consume()) {
        unawaited(_unlock());
      }
    } on Object catch (_) {}
  }

  Future<void> _unlock() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock Nox to access your wallet',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (!mounted) return;
      if (ok) {
        ref.read(isUnlockedProvider.notifier).unlock();
      } else {
        setState(() => _error = 'Authentication cancelled');
        unawaited(_shakeCtrl.forward(from: 0));
      }
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Authentication failed');
      unawaited(_shakeCtrl.forward(from: 0));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    return Scaffold(
      backgroundColor: col.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo ────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/nox_logo.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Nox',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: col.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your Ethereum wallet',
              style: AppTextStyles.bodyMedium.copyWith(color: col.textSecondary),
            ),

            const SizedBox(height: 48),

            // ── Unlock button ────────────────────────────────────────────
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) {
                final offset = _shakeAnim.value == 0
                    ? 0.0
                    : (8 *
                                  (1 - _shakeAnim.value) *
                                  (_shakeCtrl.lastElapsedDuration?.inMilliseconds ?? 0)
                                      .toDouble()
                                      .remainder(20) >
                              10
                          ? 6.0
                          : -6.0);
                return Transform.translate(offset: Offset(offset, 0), child: child);
              },
              child: _UnlockButton(loading: _loading, hasTouchId: _hasTouchId, onTap: _unlock),
            ),

            // ── Error message ────────────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: AppTextStyles.bodySmall.copyWith(color: col.error),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Unlock button
// ---------------------------------------------------------------------------

class _UnlockButton extends StatefulWidget {
  const _UnlockButton({required this.loading, required this.hasTouchId, required this.onTap});

  final bool loading;
  final bool hasTouchId;
  final VoidCallback onTap;

  @override
  State<_UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<_UnlockButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? col.primary.withValues(alpha: 0.9) : col.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: col.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.hasTouchId ? Icons.fingerprint_rounded : Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.hasTouchId ? 'Unlock with Touch ID' : 'Unlock',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
