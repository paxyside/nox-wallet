import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/services/notification_copy.dart';
import 'package:nox/core/services/notification_history_provider.dart';
import 'package:nox/core/services/notification_settings_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/format.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/mini_switch.dart';
import 'package:url_launcher/url_launcher.dart';

// Library file — split into `parts/*.dart` so private widgets stay
// private (Dart privacy is per-library, not per-file).
part 'parts/header.dart';
part 'parts/tabs.dart';
part 'parts/list.dart';
part 'parts/settings.dart';

/// Opens the notification center as a full-window modal overlay.
/// Returned future completes when the user dismisses (close button,
/// barrier tap, or Escape).
Future<void> showNotificationCenter(BuildContext context) {
  return showAppDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _NotificationCenterShell(),
  );
}

/// Modal shell that sits above the current screen, leaves a margin on
/// all sides so the underlying app stays peek-visible, and contains the
/// list + settings panel.
class _NotificationCenterShell extends StatelessWidget {
  const _NotificationCenterShell();

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: col.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: col.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const _NotificationCenterBody(),
          ),
        ),
      ),
    );
  }
}

enum _Tab { all, transactions, system, unread }

/// Returns the on-chain hash for events that carry one — used by the
/// list tap handler to deep-link into Etherscan. Empty for system
/// alerts (gas / low balance) where there's no associated tx.
String _txHashOf(WalletEvent e) {
  if (e.transaction != null) return e.transaction!.txHash;
  return '';
}

class _NotificationCenterBody extends ConsumerStatefulWidget {
  const _NotificationCenterBody();

  @override
  ConsumerState<_NotificationCenterBody> createState() => _NotificationCenterBodyState();
}

class _NotificationCenterBodyState extends ConsumerState<_NotificationCenterBody> {
  _Tab _selected = _Tab.all;
  bool _showSettings = false;

  bool _matchesTab(WalletEvent e, _Tab tab) {
    switch (tab) {
      case _Tab.all:
        return true;
      case _Tab.transactions:
        return e.kind == WalletEventKind.transaction;
      case _Tab.system:
        return e.kind == WalletEventKind.gasAlert || e.kind == WalletEventKind.lowBalance;
      case _Tab.unread:
        return !e.isRead;
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final events = ref.watch(notificationHistoryProvider);
    final unread = events.where((e) => !e.isRead).length;
    final filtered = events.where((e) => _matchesTab(e, _selected)).toList();

    return Material(
      color: col.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            unread: unread,
            settingsActive: _showSettings,
            onToggleSettings: () => setState(() => _showSettings = !_showSettings),
            onMarkAllRead: unread == 0
                ? null
                : () => unawaited(ref.read(notificationHistoryProvider.notifier).markAllRead()),
            onClearAll: events.isEmpty ? null : () => unawaited(_confirmClear(context, ref)),
            onClose: () => Navigator.of(context).pop(),
          ),
          Divider(height: 1, color: col.border),
          if (_showSettings)
            const Expanded(child: _SettingsPanel())
          else
            Expanded(
              child: Column(
                children: [
                  _TabBar(
                    selected: _selected,
                    unread: unread,
                    onChanged: (t) => setState(() => _selected = t),
                  ),
                  Divider(height: 1, color: col.border),
                  Expanded(
                    child: filtered.isEmpty
                        ? _EmptyState(tab: _selected)
                        : _List(
                            events: filtered,
                            onTap: (e) {
                              if (e.id.isNotEmpty && !e.isRead) {
                                unawaited(
                                  ref.read(notificationHistoryProvider.notifier).markRead(e.id),
                                );
                              }
                              // For transaction events, open Etherscan
                              // in the user's browser. Mirrors what the
                              // history tile does. System alerts (gas /
                              // low balance) have no hash to link, so
                              // those are just mark-read no-ops.
                              final hash = _txHashOf(e);
                              if (hash.isNotEmpty) {
                                unawaited(launchUrl(Uri.parse('https://etherscan.io/tx/$hash')));
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final col = context.colors;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: col.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Clear all notifications?',
          style: AppTextStyles.h3.copyWith(color: col.textPrimary),
        ),
        content: Text(
          'This permanently removes every entry from your notification history. New events will continue to arrive normally.',
          style: AppTextStyles.bodyMedium.copyWith(color: col.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: col.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Clear all',
              style: TextStyle(color: col.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(notificationHistoryProvider.notifier).clearAll();
  }
}
