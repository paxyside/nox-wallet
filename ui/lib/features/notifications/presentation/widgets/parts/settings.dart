part of '../notification_center.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Settings panel — toggles, auto-delete chip selector
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final asyncSettings = ref.watch(notificationSettingsCtrlProvider);

    return asyncSettings.when(
      loading: () => Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: col.textDisabled),
        ),
      ),
      error: (_, _) => Center(
        child: Text(
          'Could not load settings',
          style: AppTextStyles.bodyMedium.copyWith(color: col.error),
        ),
      ),
      data: (s) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _SettingsSection(
            title: 'Delivery',
            children: [
              _SettingsToggleRow(
                icon: Icons.notifications_active_rounded,
                title: 'macOS toasts',
                subtitle: 'Show native macOS notifications for incoming wallet events.',
                value: s.macosToasts,
                onChanged: (v) => ref
                    .read(notificationSettingsCtrlProvider.notifier)
                    .save(s.copyWith(macosToasts: v)),
              ),
              _SettingsRowDivider(),
              _SettingsToggleRow(
                icon: Icons.volume_up_rounded,
                title: 'Sound',
                subtitle: 'Play a chime when a notification arrives.',
                value: s.playSound,
                onChanged: (v) => ref
                    .read(notificationSettingsCtrlProvider.notifier)
                    .save(s.copyWith(playSound: v)),
              ),
              _SettingsRowDivider(),
              _SettingsToggleRow(
                icon: Icons.volume_off_rounded,
                title: 'Mute system alerts',
                subtitle: 'Hide gas spikes and low-balance warnings from the toast feed.',
                value: s.muteSystemAlerts,
                onChanged: (v) => ref
                    .read(notificationSettingsCtrlProvider.notifier)
                    .save(s.copyWith(muteSystemAlerts: v)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: 'Inbox behaviour',
            children: [
              _SettingsToggleRow(
                icon: Icons.mark_email_read_rounded,
                title: 'Auto-mark as read',
                subtitle: 'New notifications arrive already marked read — useful as an audit log.',
                value: s.autoMarkRead,
                onChanged: (v) => ref
                    .read(notificationSettingsCtrlProvider.notifier)
                    .save(s.copyWith(autoMarkRead: v)),
              ),
              _SettingsRowDivider(),
              _AutoDeleteRow(
                value: s.autoDeleteDays,
                onChanged: (days) => ref
                    .read(notificationSettingsCtrlProvider.notifier)
                    .save(s.copyWith(autoDeleteDays: days)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: col.textDisabled,
              fontSize: 10.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: col.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: col.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsRowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, color: context.colors.border),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: col.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: col.textPrimary,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: col.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Project-wide MiniSwitch — same 34x20 size + colours used
            // in Settings. Replaces Material's bulky Switch.adaptive
            // wrapped in Transform.scale (which scaled but didn't fix
            // the Material palette mismatch in dark theme).
            MiniSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _AutoDeleteRow extends StatelessWidget {
  const _AutoDeleteRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _options = <(int, String)>[
    (0, 'Never'),
    (7, '7 days'),
    (30, '30 days'),
    (90, '90 days'),
  ];

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Icon(Icons.auto_delete_rounded, size: 18, color: col.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-delete',
                  style: AppTextStyles.labelMedium.copyWith(color: col.textPrimary, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Drop notifications older than the chosen retention window.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: col.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AutoDeleteSegmented(value: value, options: _options, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Sliding segmented control — the selected pill animates between
/// options instead of fading. Borrows the same easing/duration as
/// `MiniSwitch` so all stateful settings widgets feel like one family.
class _AutoDeleteSegmented extends StatelessWidget {
  const _AutoDeleteSegmented({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int value;
  final List<(int, String)> options;
  final ValueChanged<int> onChanged;

  // Layout constants — tuned together so the pill aligns exactly with
  // each option's tap target.
  static const _chipPaddingH = 12.0;
  static const _outerPaddingH = 4.0;
  static const _outerPaddingV = 3.0;

  // Approximate widths of each option's text. Kept hand-tuned because
  // measuring TextPainter at build-time is expensive and we know the
  // four labels are fixed.
  static const _labelWidths = <int, double>{0: 36, 7: 44, 30: 50, 90: 50};

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    // Compute cumulative offsets to the left of each chip so the
    // sliding indicator knows where to animate to.
    final widths = <double>[];
    for (final opt in options) {
      widths.add((_labelWidths[opt.$1] ?? 50) + _chipPaddingH * 2);
    }
    final selectedIndex = options.indexWhere((o) => o.$1 == value);
    var indicatorLeft = _outerPaddingH;
    for (var i = 0; i < selectedIndex && i < widths.length; i++) {
      indicatorLeft += widths[i];
    }
    final indicatorWidth = selectedIndex >= 0 && selectedIndex < widths.length
        ? widths[selectedIndex]
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _outerPaddingH,
        vertical: _outerPaddingV,
      ),
      decoration: BoxDecoration(
        color: col.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.border),
      ),
      child: Stack(
        children: [
          // Sliding indicator — animates left + width when selection
          // changes. AnimatedPositioned matches the easing curve from
          // MiniSwitch so the two widgets feel like the same primitive.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: indicatorLeft - _outerPaddingH,
            top: 0,
            bottom: 0,
            width: indicatorWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: col.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final opt in options)
                _AutoDeleteChip(
                  label: opt.$2,
                  width: (_labelWidths[opt.$1] ?? 50) + _chipPaddingH * 2,
                  selected: opt.$1 == value,
                  onTap: () => onChanged(opt.$1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutoDeleteChip extends StatelessWidget {
  const _AutoDeleteChip({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          height: 24,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? col.primaryLight : col.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
