import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/settings/domain/settings_repository.dart';
import 'package:nox/features/settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// Entry point: two-step dialog (warning → reveal)
// ---------------------------------------------------------------------------

class RevealSecretDialog extends ConsumerStatefulWidget {
  const RevealSecretDialog({super.key});

  @override
  ConsumerState<RevealSecretDialog> createState() => _RevealSecretDialogState();
}

class _RevealSecretDialogState extends ConsumerState<RevealSecretDialog> {
  bool _confirmed = false;
  bool _blurred = true;

  Future<void> _reveal() async {
    // Require Touch ID / system password before exposing the secret. The
    // user has already clicked through the warning copy — this is the actual
    // gate that prevents someone with momentary access to the unlocked
    // machine from walking away with a seed phrase.
    final authed = await _authenticate();
    if (!authed) {
      if (mounted) AppSnackBar.error(context, 'Authentication failed.');
      return;
    }

    final ok = await ref.read(revealSecretNotifierProvider.notifier).reveal();
    if (!ok && mounted) {
      AppSnackBar.error(context, 'Failed to load secret.');
    } else {
      setState(() {
        _confirmed = true;
        _blurred = true;
      });
    }
  }

  Future<bool> _authenticate() async {
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      // No biometrics / passcode set up at all — fail closed.
      if (!supported) return false;

      return await auth.authenticate(
        localizedReason: 'Confirm to reveal your secret phrase',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on Object {
      return false;
    }
  }

  void _close() {
    ref.read(revealSecretNotifierProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(revealSecretNotifierProvider);

    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _confirmed
                ? _SecretView(
                    key: const ValueKey('secret'),
                    secret: state.valueOrNull?.secret ?? '',
                    kind: state.valueOrNull?.secretKind ?? SecretKind.mnemonic,
                    blurred: _blurred,
                    onToggle: () => setState(() => _blurred = !_blurred),
                    onClose: _close,
                  )
                : _WarningView(
                    key: const ValueKey('warn'),
                    loading: state.isLoading,
                    onReveal: _reveal,
                    onCancel: _close,
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — warning
// ---------------------------------------------------------------------------

class _WarningView extends StatelessWidget {
  const _WarningView({
    required this.loading,
    required this.onReveal,
    required this.onCancel,
    super.key,
  });

  final bool loading;
  final VoidCallback onReveal;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + title
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: context.colors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reveal Secret Phrase',
              style: AppTextStyles.h3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Warning text
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.error.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.colors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BulletItem(
                'Never share your secret phrase with anyone.',
                context,
              ),
              const SizedBox(height: 6),
              _BulletItem(
                'Anyone with this phrase can steal all your funds.',
                context,
              ),
              const SizedBox(height: 6),
              _BulletItem(
                'Paxy will never ask you for it.',
                context,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: loading ? null : onCancel,
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: loading ? null : onReveal,
              icon: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: context.colors.textPrimary,
                      ),
                    )
                  : const Icon(Icons.lock_open_rounded, size: 16),
              label: const Text('Show anyway'),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTextStyles.labelLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text, this.context);
  final String text;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.error,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — secret display
// ---------------------------------------------------------------------------

class _SecretView extends StatelessWidget {
  const _SecretView({
    required this.secret,
    required this.kind,
    required this.blurred,
    required this.onToggle,
    required this.onClose,
    super.key,
  });

  final String secret;
  final SecretKind kind;
  final bool blurred;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  bool get _isMnemonic => kind == SecretKind.mnemonic;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: secret));
    if (context.mounted) {
      AppSnackBar.success(
        context,
        _isMnemonic ? 'Seed phrase copied.' : 'Private key copied.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.key_rounded,
                color: context.colors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isMnemonic ? 'Seed Phrase' : 'Private Key',
              style: AppTextStyles.h3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Secret box with blur overlay
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.border),
              ),
              child: _isMnemonic
                  ? _MnemonicGrid(words: secret.trim().split(' '))
                  : SelectableText(
                      secret,
                      style: AppTextStyles.mono.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
            ),
            // Blur overlay
            if (blurred)
              Positioned.fill(
                child: GestureDetector(
                  onTap: onToggle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: context.colors.surface.withValues(alpha: 0.85),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_rounded,
                            color: context.colors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Click to reveal',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Toggle hint
        if (!blurred)
          GestureDetector(
            onTap: onToggle,
            child: Text(
              'Click to hide',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textDisabled,
              ),
            ),
          ),

        const SizedBox(height: 20),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded, size: 15),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.textSecondary,
                side: BorderSide(color: context.colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTextStyles.labelLarge,
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onClose,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTextStyles.labelLarge,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mnemonic word grid (2 columns)
// ---------------------------------------------------------------------------

class _MnemonicGrid extends StatelessWidget {
  const _MnemonicGrid({required this.words});
  final List<String> words;

  @override
  Widget build(BuildContext context) {
    // Split into two columns
    final half = (words.length / 2).ceil();
    final col1 = words.take(half).toList();
    final col2 = words.skip(half).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _WordColumn(words: col1, startIndex: 1)),
        const SizedBox(width: 16),
        Expanded(
          child: _WordColumn(words: col2, startIndex: half + 1),
        ),
      ],
    );
  }
}

class _WordColumn extends StatelessWidget {
  const _WordColumn({required this.words, required this.startIndex});
  final List<String> words;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < words.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${startIndex + i}.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textDisabled,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  words[i],
                  style: AppTextStyles.mono.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
