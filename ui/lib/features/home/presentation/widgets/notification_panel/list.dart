part of '../wallet_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// List
// ─────────────────────────────────────────────────────────────────────────────

class _List extends StatelessWidget {
  const _List({required this.events});

  final List<WalletEvent> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final event = events[i];
        // Per-row read flag — no more index/lastSeen math.
        return _NotificationTile(event: event, isUnread: !event.isRead);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.event, required this.isUnread});

  final WalletEvent event;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBlock(event: event, isUnread: isUnread),
            const SizedBox(width: 12),
            Expanded(child: _TextBlock(event: event)),
            const SizedBox(width: 8),
            _Trailing(event: event),
          ],
        ),
      ),
    );
  }
}

class _IconBlock extends StatelessWidget {
  const _IconBlock({required this.event, required this.isUnread});

  final WalletEvent event;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = _iconData(context, event);
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          if (isUnread)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

(IconData, Color) _iconData(BuildContext context, WalletEvent event) {
  final colors = context.colors;
  switch (event.kind) {
    case WalletEventKind.transaction:
      final tx = event.transaction!;
      switch (tx.role) {
        case TxRole.sendEth:
        case TxRole.sendToken:
          return (Icons.arrow_upward_rounded, colors.error);
        case TxRole.receiveEth:
        case TxRole.receiveToken:
          return (Icons.arrow_downward_rounded, colors.success);
        case TxRole.swap:
          return (Icons.swap_horiz_rounded, colors.primary);
        case TxRole.selfTransfer:
          return (Icons.refresh_rounded, colors.textSecondary);
        case TxRole.approve:
          return (Icons.check_rounded, colors.warning);
        case TxRole.unknown:
          return (Icons.help_outline_rounded, colors.textSecondary);
      }
    case WalletEventKind.gasAlert:
      final e = event.gasAlert!;
      return e.isSpike
          ? (Icons.local_gas_station_rounded, colors.warning)
          : (Icons.local_gas_station_rounded, colors.success);
    case WalletEventKind.lowBalance:
      return (Icons.warning_amber_rounded, colors.warning);
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.event});

  final WalletEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final copy = NotificationCopy.forEventPanel(event);
    final (title, subtitle) = copy != null ? (copy.title, copy.body) : ('', '');

    final ts = event.transaction?.timestamp ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.5, color: colors.textSecondary, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          timeAgo(ts),
          style: TextStyle(fontSize: 11.5, color: colors.textDisabled, height: 1.2),
        ),
      ],
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.event});

  final WalletEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    switch (event.kind) {
      case WalletEventKind.transaction:
        return _txTrailing(context, event.transaction!);
      case WalletEventKind.gasAlert:
        final e = event.gasAlert!;
        return Text(
          '${e.currentGwei} Gwei',
          style: TextStyle(fontSize: 11, color: colors.warning, fontWeight: FontWeight.w600),
        );
      case WalletEventKind.lowBalance:
        return const SizedBox.shrink();
    }
  }

  Widget _txTrailing(BuildContext context, TransactionEvent tx) {
    final colors = context.colors;
    switch (tx.role) {
      case TxRole.swap:
        final out = tx.outgoing.firstOrNull;
        final inc = tx.incoming.firstOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (out != null)
              Text(
                '-${formatAmount(out.amount)} ${out.displaySymbol}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.error),
              ),
            if (inc != null)
              Text(
                '+${formatAmount(inc.amount)} ${inc.displaySymbol}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.success),
              ),
          ],
        );
      case TxRole.sendEth:
      case TxRole.sendToken:
        final out = tx.outgoing.firstOrNull;
        if (out == null) return const SizedBox.shrink();
        return Text(
          '-${formatAmount(out.amount)} ${out.displaySymbol}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.error),
        );
      case TxRole.receiveEth:
      case TxRole.receiveToken:
        final inc = tx.incoming.firstOrNull;
        if (inc == null) return const SizedBox.shrink();
        return Text(
          '+${formatAmount(inc.amount)} ${inc.displaySymbol}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.success),
        );
      case TxRole.selfTransfer:
        final out = tx.outgoing.firstOrNull;
        if (out == null) return const SizedBox.shrink();
        return Text(
          '${formatAmount(out.amount)} ${out.displaySymbol}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
        );
      case TxRole.approve:
      case TxRole.unknown:
        return const SizedBox.shrink();
    }
  }
}
