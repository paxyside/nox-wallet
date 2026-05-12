part of '../wallet_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});

  final _Tab tab;

  String get _subtitle => switch (tab) {
    _Tab.all => 'No new wallet activity yet',
    _Tab.transactions => 'No transactions yet',
    _Tab.system => 'No system alerts',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.notifications_none_rounded, size: 18, color: colors.textDisabled),
          ),
          const SizedBox(height: 10),
          Text(
            'Nothing here yet',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(_subtitle, style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onViewAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View all notifications',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 13, color: colors.textPrimary),
          ],
        ),
      ),
    );
  }
}
