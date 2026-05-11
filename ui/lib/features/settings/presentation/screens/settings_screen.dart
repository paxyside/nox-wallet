import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/state/auto_lock_provider.dart';
import 'package:nox/core/state/privacy_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/copy_button.dart';
import 'package:nox/core/widgets/themed_dropdown.dart';
import 'package:nox/features/settings/domain/settings_repository.dart';
import 'package:nox/features/settings/presentation/providers/settings_provider.dart';
import 'package:nox/features/settings/presentation/widgets/export_keystore_dialog.dart';
import 'package:nox/features/settings/presentation/widgets/reveal_secret_dialog.dart';
import 'package:nox/features/settings/presentation/widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletSettingsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Comfortable reading width, centred on wide screens.
          const maxContent = 680.0;
          const minHPad = 40.0;
          final hPad = ((constraints.maxWidth - maxContent) / 2).clamp(
            minHPad,
            double.infinity,
          );

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 18),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Page header ───────────────────────────────────────
                    Text(
                      'Settings',
                      style: AppTextStyles.h2.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage your wallet, security, and preferences.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Wallet ─────────────────────────────────────────────
                    walletAsync.when(
                      loading: () => const _WalletSectionSkeleton(),
                      error: (err, _) => _ErrorBanner(message: errorMessage(err)),
                      data: (wallet) => _WalletSection(wallet: wallet),
                    ),

                    const SizedBox(height: 14),

                    // ── Security ───────────────────────────────────────────
                    SettingsSection(
                      title: 'Security',
                      rows: [
                        SettingsRow(
                          label: 'Auto-lock',
                          subtitle: 'Lock the wallet after this much idle time',
                          trailing: _AutoLockSelector(
                            value: ref.watch(autoLockSettingProvider),
                            onChanged: (v) =>
                                ref.read(autoLockSettingProvider.notifier).setTimeout(v),
                          ),
                        ),
                        SettingsRow(
                          label: 'Hide balances',
                          subtitle: 'Mask all amounts as ••••••',
                          trailing: _MiniSwitch(
                            value: ref.watch(hideBalancesProvider),
                            onChanged: (_) => ref.read(hideBalancesProvider.notifier).toggle(),
                          ),
                        ),
                        SettingsRow(
                          label: 'Reveal Secret Phrase',
                          subtitle: 'View your seed phrase or private key',
                          trailing: _ActionButton(
                            label: 'Reveal',
                            icon: Icons.visibility_outlined,
                            onTap: () => _showRevealDialog(context),
                          ),
                        ),
                        SettingsRow(
                          label: 'Export Keystore',
                          trailing: _ActionButton(
                            label: 'Export',
                            icon: Icons.download_outlined,
                            onTap: () => _showExportDialog(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Danger Zone ────────────────────────────────────────
                    SettingsSection(
                      title: 'Danger Zone',
                      titleColor: context.colors.error,
                      rows: [
                        SettingsRow(
                          label: 'Import new wallet',
                          trailing: _ActionButton(
                            label: 'Import',
                            icon: Icons.swap_horiz,
                            color: context.colors.error,
                            onTap: () => _confirmImportNewWallet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRevealDialog(BuildContext context) {
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (_) => const RevealSecretDialog(),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (_) => const ExportKeystoreDialog(),
      ),
    );
  }

  Future<void> _confirmImportNewWallet(BuildContext context) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Replace Wallet?',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
        content: Text(
          'This will replace your current wallet. Make sure you have a backup.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.go(Routes.onboarding);
    }
  }
}

// ---------------------------------------------------------------------------
// Wallet section — built separately to keep the main build clean
// ---------------------------------------------------------------------------

class _WalletSection extends StatelessWidget {
  const _WalletSection({required this.wallet});

  final WalletSettings wallet;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Wallet',
      rows: [
        SettingsRow(
          label: 'Address',
          trailing: _CopyableAddress(address: wallet.address),
        ),
        SettingsRow(
          label: 'Label',
          value: wallet.label.isEmpty ? '—' : wallet.label,
        ),
        SettingsRow(
          label: 'Secret Type',
          trailing: _SecretTypeBadge(secretKind: wallet.secretKind),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Copyable address widget
// ---------------------------------------------------------------------------

class _CopyableAddress extends StatelessWidget {
  const _CopyableAddress({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final short = address.length > 16
        ? '${address.substring(0, 8)}…${address.substring(address.length - 6)}'
        : address;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          address.isEmpty ? '—' : short,
          style: AppTextStyles.mono.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        if (address.isNotEmpty) ...[
          const SizedBox(width: 6),
          CopyButton(
            value: address,
            successMessage: 'Address copied.',
            tooltip: 'Copy address',
            size: 14,
            color: context.colors.textSecondary,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Secret type badge
// ---------------------------------------------------------------------------

class _SecretTypeBadge extends StatelessWidget {
  const _SecretTypeBadge({required this.secretKind});

  final SecretKind secretKind;

  @override
  Widget build(BuildContext context) {
    final label = switch (secretKind) {
      SecretKind.mnemonic => 'Mnemonic',
      SecretKind.privateKey => 'Private Key',
      SecretKind.unspecified => 'Unknown',
    };

    final color = switch (secretKind) {
      SecretKind.mnemonic => context.colors.success,
      SecretKind.privateKey => context.colors.primaryLight,
      SecretKind.unspecified => context.colors.textDisabled,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline action button (used in settings rows)
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.colors.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon != null ? Icon(icon, size: 15, color: foreground) : const SizedBox.shrink(),
      label: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: foreground),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(color: foreground.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loader while wallet data is loading
// ---------------------------------------------------------------------------

class _WalletSectionSkeleton extends StatelessWidget {
  const _WalletSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Wallet',
      rows: [
        SettingsRow(label: 'Address', value: '—'),
        SettingsRow(label: 'Label', value: '—'),
        SettingsRow(label: 'Secret Type', value: '—'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Failed to load wallet: $message',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact themed switch — replaces Switch.adaptive in settings rows.
// Material's adaptive switch is large and uses Material colors that don't
// match our palette in either theme; this draws its own track + thumb in the
// app's primary / border colors.
// ---------------------------------------------------------------------------

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _trackWidth = 34.0;
  static const _trackHeight = 20.0;
  static const _thumbSize = 14.0;
  static const _padding = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trackOn = colors.primary;
    final trackOff = colors.surfaceHigh;
    final borderOn = colors.primary.withValues(alpha: 0.6);
    final borderOff = colors.border;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: _trackWidth,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: value ? trackOn : trackOff,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            border: Border.all(
              color: value ? borderOn : borderOff,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: value ? _trackWidth - _thumbSize - _padding - 2 : _padding - 1,
                top: (_trackHeight - _thumbSize) / 2 - 1,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : colors.textSecondary,
                    shape: BoxShape.circle,
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoLockSelector extends StatelessWidget {
  const _AutoLockSelector({required this.value, required this.onChanged});

  final AutoLockTimeout value;
  final ValueChanged<AutoLockTimeout> onChanged;

  @override
  Widget build(BuildContext context) {
    return ThemedDropdown<AutoLockTimeout>(
      value: value,
      items: [
        for (final t in AutoLockTimeout.values) ThemedDropdownItem(value: t, label: t.label),
      ],
      onChanged: onChanged,
    );
  }
}
