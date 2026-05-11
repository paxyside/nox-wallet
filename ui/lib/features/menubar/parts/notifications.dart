part of '../mini_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notifications sub-view widgets — link, tile, empty state
// ─────────────────────────────────────────────────────────────────────────────

class _MarkAllReadLink extends StatefulWidget {
  const _MarkAllReadLink({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_MarkAllReadLink> createState() => _MarkAllReadLinkState();
}

class _MarkAllReadLinkState extends State<_MarkAllReadLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'Mark all read',
          style: AppTextStyles.bodySmall.copyWith(
            color: _hovered ? col.primary : col.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MiniNotificationTile extends StatelessWidget {
  const _MiniNotificationTile({required this.event, required this.isUnread});

  final WalletEvent event;
  final bool isUnread;

  (IconData, Color) _icon(BuildContext context) {
    final col = context.colors;
    switch (event.kind) {
      case WalletEventKind.transaction:
        final tx = event.transaction!;
        switch (tx.role) {
          case TxRole.sendEth:
          case TxRole.sendToken:
            return (Icons.arrow_upward_rounded, col.warning);
          case TxRole.receiveEth:
          case TxRole.receiveToken:
            return (Icons.arrow_downward_rounded, col.success);
          case TxRole.swap:
            return (Icons.swap_horiz_rounded, col.primary);
          case TxRole.selfTransfer:
            return (Icons.refresh_rounded, col.textSecondary);
          case TxRole.approve:
            return (Icons.check_rounded, col.warning);
          case TxRole.unknown:
            return (Icons.help_outline_rounded, col.textSecondary);
        }
      case WalletEventKind.gasAlert:
        return (Icons.local_gas_station_rounded, col.warning);
      case WalletEventKind.lowBalance:
        return (Icons.warning_amber_rounded, col.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final (icon, color) = _icon(context);
    final copy = NotificationCopy.forEventPanel(event);
    final title = copy?.title ?? 'Wallet event';
    final subtitle = copy?.body ?? '';
    final ts = event.transaction?.timestamp ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: col.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (isUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: col.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: col.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: col.textPrimary,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: col.textSecondary,
                      fontSize: 11.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  timeAgo(ts),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: col.textDisabled,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  const _MiniEmpty({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: col.textDisabled),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: col.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: col.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
