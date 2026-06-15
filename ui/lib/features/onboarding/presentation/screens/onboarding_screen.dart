import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/router/router.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/features/onboarding/presentation/screens/generate_wallet_screen.dart';
import 'package:nox/features/onboarding/presentation/screens/import_keystore_screen.dart';
import 'package:nox/features/onboarding/presentation/screens/import_mnemonic_screen.dart';
import 'package:nox/features/onboarding/presentation/screens/import_private_key_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void dispose() {
    // Re-arm the redirect guard once we leave onboarding — whether the
    // replace completed (screen navigated home) or the user backed out.
    // Deferred to after the current frame so we don't mutate provider
    // state mid-dispose/build. The provider is keepAlive (plain
    // StateProvider), so reading it post-dispose is safe.
    final container = ProviderScope.containerOf(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      container.read(replaceWalletIntentProvider.notifier).state = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Logo(),
                const SizedBox(height: 48),
                Text(
                  'Welcome to Nox Wallet',
                  style: AppTextStyles.h1.copyWith(color: context.colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'A secure, self-custodial Ethereum wallet for macOS.',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 56),
                _PrimaryButton(
                  label: 'Create new wallet',
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => const GenerateWalletScreen())),
                ),
                const SizedBox(height: 16),
                _SecondaryButton(
                  label: 'Import existing wallet',
                  onPressed: () => _showImportSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImportSheet(BuildContext context) {
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (_) => _ImportDialog(parentContext: context),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        child: Image(
          image: AssetImage('assets/images/nox_logo.png'),
          width: 128,
          height: 128,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colors.textPrimary,
          side: BorderSide(color: context.colors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
        ),
      ),
    );
  }
}

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 440,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Import wallet',
                      style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.colors.textSecondary, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how you want to import your wallet.',
                style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 24),
              _ImportOption(
                icon: Icons.text_fields_rounded,
                title: 'Recovery phrase',
                subtitle: '12 or 24 word mnemonic',
                onTap: () {
                  Navigator.pop(context);
                  unawaited(
                    Navigator.of(
                      parentContext,
                    ).push(MaterialPageRoute<void>(builder: (_) => const ImportMnemonicScreen())),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ImportOption(
                icon: Icons.key_rounded,
                title: 'Private key',
                subtitle: 'Hex-encoded private key',
                onTap: () {
                  Navigator.pop(context);
                  unawaited(
                    Navigator.of(
                      parentContext,
                    ).push(MaterialPageRoute<void>(builder: (_) => const ImportPrivateKeyScreen())),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ImportOption(
                icon: Icons.folder_zip_outlined,
                title: 'Keystore file',
                subtitle: 'Encrypted JSON keystore',
                onTap: () {
                  Navigator.pop(context);
                  unawaited(
                    Navigator.of(
                      parentContext,
                    ).push(MaterialPageRoute<void>(builder: (_) => const ImportKeystoreScreen())),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportOption extends StatelessWidget {
  const _ImportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.colors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
