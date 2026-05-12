part of '../mini_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Home view — primary popover content
// ─────────────────────────────────────────────────────────────────────────────

class _HomeView extends ConsumerWidget {
  const _HomeView({
    required this.onOpenAt,
    required this.onQuit,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final void Function(String route) onOpenAt;
  final VoidCallback onQuit;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(onOpenNotifications: onOpenNotifications),
        const SizedBox(height: 12),
        _BalanceCard(homeAsync: homeAsync),
        const SizedBox(height: 12),
        _QuickActions(
          onDashboard: () => onOpenAt(Routes.home),
          onSend: () => onOpenAt(Routes.send),
          onSwap: () => onOpenAt(Routes.swap),
        ),
        const SizedBox(height: 12),
        Expanded(child: _LastActivity(onSeeAll: () => onOpenAt(Routes.history))),
        const SizedBox(height: 8),
        _Footer(onSettings: onOpenSettings, onQuit: onQuit),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications sub-view — opens via the bell, replaces home in-place
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsView extends ConsumerWidget {
  const _NotificationsView({required this.onBack, required this.onViewAll, required this.onQuit});

  final VoidCallback onBack;
  final VoidCallback onViewAll;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(notificationHistoryProvider);
    final unread = events.where((e) => !e.isRead).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubviewHeader(
          title: 'Notifications',
          onBack: onBack,
          trailing: unread > 0
              ? _MarkAllReadLink(
                  onTap: () =>
                      unawaited(ref.read(notificationHistoryProvider.notifier).markAllRead()),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: events.isEmpty
              ? const _MiniEmpty(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications yet',
                  subtitle: 'New transactions and alerts will show up here.',
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = events[i];
                    return _MiniNotificationTile(event: e, isUnread: !e.isRead);
                  },
                ),
        ),
        const SizedBox(height: 8),
        _Footer(
          onSettings: onViewAll,
          onQuit: onQuit,
          settingsLabel: 'View all',
          settingsIcon: Icons.open_in_new_rounded,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings sub-view — opens via the footer gear, replaces home in-place
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsView extends ConsumerWidget {
  const _SettingsView({
    required this.onBack,
    required this.onOpenFullSettings,
    required this.onQuit,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenFullSettings;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final isDark = ref.watch(themeModeNotifierProvider) == ThemeMode.dark;
    final hideBalances = ref.watch(hideBalancesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubviewHeader(title: 'Settings', onBack: onBack),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _SettingsCard(
                children: [
                  _SettingsToggleRow(
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    label: 'Dark mode',
                    value: isDark,
                    onChanged: (_) => ref.read(themeModeNotifierProvider.notifier).toggle(),
                  ),
                  _SettingsRowDivider(),
                  _SettingsToggleRow(
                    icon: Icons.visibility_off_rounded,
                    label: 'Hide balances',
                    value: hideBalances,
                    onChanged: (_) => ref.read(hideBalancesProvider.notifier).toggle(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsTapRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Lock wallet now',
                    iconColor: col.warning,
                    onTap: () {
                      ref.read(isUnlockedProvider.notifier).lock();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsTapRow(
                    icon: Icons.tune_rounded,
                    label: 'All settings',
                    trailing: Icon(Icons.chevron_right_rounded, size: 16, color: col.textSecondary),
                    onTap: onOpenFullSettings,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Footer(onSettings: onOpenFullSettings, onQuit: onQuit, settingsLabel: 'All settings'),
      ],
    );
  }
}
