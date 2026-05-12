part of '../notification_center.dart';

// ─────────────────────────────────────────────────────────────────────────────
// List + Tile + Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _List extends StatelessWidget {
  const _List({required this.events, required this.onTap});

  final List<WalletEvent> events;
  final ValueChanged<WalletEvent> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _Tile(event: events[i], onTap: () => onTap(events[i])),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({required this.event, required this.onTap});
  final WalletEvent event;
  final VoidCallback onTap;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _hovered = false;

  (IconData, Color) _icon(BuildContext context) {
    final col = context.colors;
    switch (widget.event.kind) {
      case WalletEventKind.transaction:
        final tx = widget.event.transaction!;
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
    final copy = NotificationCopy.forEventPanel(widget.event);
    final title = copy?.title ?? 'Wallet event';
    final body = copy?.body ?? '';
    final ts = widget.event.transaction?.timestamp ?? DateTime.now();
    final isUnread = !widget.event.isRead;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _hovered ? col.surface : col.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isUnread ? col.primary.withValues(alpha: 0.45) : col.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  if (isUnread)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: col.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: col.surfaceHigh, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: col.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: col.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      timeAgo(ts),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: col.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final _Tab tab;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final (icon, title, sub) = switch (tab) {
      _Tab.all => (
        Icons.notifications_none_rounded,
        'No notifications yet',
        'Wallet events and alerts will appear here.',
      ),
      _Tab.transactions => (
        Icons.swap_horiz_rounded,
        'No transactions yet',
        'Sent, received and swap activity shows up here.',
      ),
      _Tab.system => (
        Icons.local_gas_station_rounded,
        'No system alerts',
        'Gas spikes and low balance warnings will appear here.',
      ),
      _Tab.unread => (Icons.done_all_rounded, "You're all caught up", 'Nothing unread.'),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: col.textDisabled),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(color: col.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: col.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
