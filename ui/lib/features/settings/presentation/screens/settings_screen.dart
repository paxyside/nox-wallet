import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/app_info.dart';
import 'package:nox/core/router/router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/services/update_service.dart';
import 'package:nox/core/state/auto_lock_provider.dart';
import 'package:nox/core/state/privacy_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/copy_button.dart';
import 'package:nox/core/widgets/mini_switch.dart';
import 'package:nox/core/widgets/themed_dropdown.dart';
import 'package:nox/features/settings/domain/settings_repository.dart';
import 'package:nox/features/settings/presentation/providers/settings_provider.dart';
import 'package:nox/features/settings/presentation/widgets/compact_settings_row.dart';
import 'package:nox/features/settings/presentation/widgets/export_keystore_dialog.dart';
import 'package:nox/features/settings/presentation/widgets/reveal_secret_dialog.dart';

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
          final hPad = ((constraints.maxWidth - maxContent) / 2).clamp(minHPad, double.infinity);

          // The full settings column overflows the available height once
          // the About / Danger sections are added — wrap in a
          // SingleChildScrollView so everything stays reachable in
          // narrow windows (mini widget, small monitors) without
          // perfecting the visual rhythm yet. Layout polish lives in a
          // follow-up todo.
          return SingleChildScrollView(
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
                      style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage your wallet, security, and preferences.',
                      style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                    ),

                    const SizedBox(height: 12),

                    // ── Wallet ─────────────────────────────────────────────
                    // 2-cell CompactSettingsRow (Label+Address / Secret type)
                    // instead of the legacy 3-stacked-row layout —
                    // saves ~80px of vertical space so Settings fits in
                    // a single viewport.
                    walletAsync.when(
                      loading: () => const _WalletSectionSkeleton(),
                      error: (err, _) => _ErrorBanner(message: errorMessage(err)),
                      data: (wallet) => _WalletSection(wallet: wallet),
                    ),

                    const SizedBox(height: 10),

                    // ── Security (top row): Auto-lock + Hide balances ──────
                    // Two short selectors that fit comfortably side-by-side.
                    CompactSettingsRow(
                      title: 'Security',
                      cells: [
                        CompactSettingsCell(
                          icon: Icons.lock_outline,
                          label: 'Auto-lock',
                          // Short subtitle keeps visual symmetry with the
                          // sibling Hide balances cell (which has one).
                          // Asymmetric cells in the same row read as
                          // accidental — content density should match.
                          subtitle: 'Lock after idle time',
                          trailing: _AutoLockSelector(
                            value: ref.watch(autoLockSettingProvider),
                            onChanged: (v) =>
                                ref.read(autoLockSettingProvider.notifier).setTimeout(v),
                          ),
                        ),
                        CompactSettingsCell(
                          icon: Icons.visibility_off_outlined,
                          label: 'Hide balances',
                          // Showing the actual portfolio value here as a
                          // "preview" was a UX paradox — a setting called
                          // "Hide balances" that displays your balance. Plain
                          // explanation reads cleaner.
                          subtitle: 'Mask balances and amounts',
                          trailing: MiniSwitch(
                            value: ref.watch(hideBalancesProvider),
                            onChanged: (_) => ref.read(hideBalancesProvider.notifier).toggle(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Security (bottom row): Reveal + Export ─────────────
                    // Visually split from the "state" controls above with
                    // its own subheading. Toggles/dropdowns are settings
                    // you set once; these are one-shot destructive-ish
                    // actions you reach for occasionally — different mental
                    // category, deserves its own header.
                    CompactSettingsRow(
                      title: 'Actions',
                      cells: [
                        CompactSettingsCell(
                          icon: Icons.vpn_key_outlined,
                          label: 'Reveal Secret Phrase',
                          subtitle: 'Seed phrase or private key',
                          // Amber tone on the icon tile AND the button —
                          // revealing the secret phrase exposes everything
                          // that can drain the wallet, so the warmer tint
                          // signals "think before you click". Export
                          // Keystore is encrypted, stays neutral ghost.
                          iconColor: AppColors.warning,
                          trailing: _ActionButton(
                            label: 'Reveal',
                            icon: Icons.visibility_outlined,
                            color: AppColors.warning,
                            onTap: () => _showRevealDialog(context),
                          ),
                        ),
                        CompactSettingsCell(
                          icon: Icons.download_outlined,
                          label: 'Export Keystore',
                          subtitle: 'Encrypted .keystore file',
                          trailing: _ActionButton(
                            label: 'Export',
                            icon: Icons.download_outlined,
                            onTap: () => _showExportDialog(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Security continuation: Active approvals ──────────
                    // The full Approvals page used to be a top-level sidebar
                    // tab — now lives behind this entry. Per-token approval
                    // status is shown contextually in each token's drawer.
                    CompactSettingsRow(
                      title: '',
                      cells: [
                        CompactSettingsCell(
                          icon: Icons.shield_outlined,
                          label: 'Active approvals',
                          subtitle: 'Review and revoke ERC-20 allowances',
                          trailing: _ActionButton(
                            label: 'Open',
                            icon: Icons.arrow_forward_rounded,
                            onTap: () => context.go(Routes.approvals),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── About ──────────────────────────────────────────────
                    CompactSettingsRow(
                      title: 'About',
                      cells: [
                        CompactSettingsCell(
                          icon: Icons.auto_awesome_outlined,
                          label: 'Updates',
                          subtitle: 'Background check runs hourly — click to force one now',
                          // Version label + Check button. "Auto-checked
                          // hourly" used to live here too but duplicated
                          // the subtitle — one statement of the cadence
                          // is enough.
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'v$kAppVersion',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: context.colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 14),
                              _ActionButton(
                                label: 'Check for updates',
                                icon: Icons.system_update_alt,
                                onTap: () => unawaited(UpdateService.checkNow()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Danger Zone ────────────────────────────────────────
                    // `danger: true` paints a red border + soft red shadow
                    // around the card so the destructive action stands
                    // visually apart from everything else above.
                    CompactSettingsRow(
                      title: 'Danger Zone',
                      titleColor: context.colors.error,
                      danger: true,
                      cells: [
                        CompactSettingsCell(
                          icon: Icons.warning_amber_outlined,
                          label: 'Import new wallet',
                          subtitle: 'Replace the current wallet using seed phrase or private key',
                          danger: true,
                          trailing: _ActionButton(
                            label: 'Import',
                            icon: Icons.swap_horiz,
                            color: context.colors.error,
                            onTap: () => _confirmImportNewWallet(context, ref),
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
    unawaited(showAppDialog<void>(context: context, builder: (_) => const RevealSecretDialog()));
  }

  void _showExportDialog(BuildContext context) {
    unawaited(showAppDialog<void>(context: context, builder: (_) => const ExportKeystoreDialog()));
  }

  Future<void> _confirmImportNewWallet(BuildContext context, WidgetRef ref) async {
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
          style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: context.colors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Signal the router to let onboarding through despite a wallet
      // still existing; OnboardingScreen clears it again on dispose.
      ref.read(replaceWalletIntentProvider.notifier).state = true;
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
    // Wallet metadata folded into a 2-cell CompactSettingsRow so the
    // section reads in one glance and doesn't burn 150px on three
    // stacked legacy rows. The address sits on the same line as its
    // copy button (mono, shortened); the type badge lives next to the
    // label cell. Saves enough vertical space to keep Settings within
    // a 1000×700 window without scrolling.
    final shortAddress = wallet.address.length > 14
        ? '${wallet.address.substring(0, 8)}…${wallet.address.substring(wallet.address.length - 6)}'
        : wallet.address;

    return CompactSettingsRow(
      title: 'Wallet',
      cells: [
        CompactSettingsCell(
          icon: Icons.account_balance_wallet_outlined,
          label: wallet.label.isEmpty ? 'Unnamed wallet' : wallet.label,
          subtitle: wallet.address.isEmpty ? '—' : shortAddress,
          trailing: wallet.address.isEmpty
              ? null
              : CopyButton(
                  value: wallet.address,
                  successMessage: 'Address copied.',
                  tooltip: 'Copy address',
                  size: 14,
                  color: context.colors.textSecondary,
                ),
        ),
        CompactSettingsCell(
          icon: Icons.key_outlined,
          label: 'Secret type',
          subtitle: switch (wallet.secretKind) {
            SecretKind.mnemonic => 'Mnemonic phrase',
            SecretKind.privateKey => 'Raw private key',
            SecretKind.unspecified => 'Unknown',
          },
          trailing: _SecretTypeBadge(secretKind: wallet.secretKind),
        ),
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

    // Secret type is a CATEGORY, not a quality assessment — strip the
    // green "good" connotation (`success`) so the badge doesn't imply
    // "mnemonic is the right answer". Everything except Unknown reads
    // as a neutral identifier.
    final color = switch (secretKind) {
      SecretKind.mnemonic => context.colors.textSecondary,
      SecretKind.privateKey => context.colors.textSecondary,
      SecretKind.unspecified => context.colors.textDisabled,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline action button (used in settings rows)
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.icon, this.color});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  /// Tint colour for accent actions. Leave null for the default "ghost"
  /// style (neutral text + soft border) used by Export and Check for
  /// updates — actions which are common, low-stakes, and shouldn't
  /// scream for attention. Pass `AppColors.warning` for caution-tier
  /// (Reveal) or `AppColors.error` for danger-tier (Import).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isAccent = color != null;
    final foreground = color ?? context.colors.textPrimary;
    final borderColor = isAccent ? color!.withValues(alpha: 0.5) : context.colors.border;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon != null ? Icon(icon, size: 15, color: foreground) : const SizedBox.shrink(),
      label: Text(label, style: AppTextStyles.labelLarge.copyWith(color: foreground)),
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(color: borderColor),
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
    return const CompactSettingsRow(
      title: 'Wallet',
      cells: [
        CompactSettingsCell(
          icon: Icons.account_balance_wallet_outlined,
          label: '—',
          subtitle: '—',
        ),
        CompactSettingsCell(icon: Icons.key_outlined, label: 'Secret type', subtitle: '—'),
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
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
            ),
          ),
        ],
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
      items: [for (final t in AutoLockTimeout.values) ThemedDropdownItem(value: t, label: t.label)],
      onChanged: onChanged,
    );
  }
}
