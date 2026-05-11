part of '../mini_widget.dart';

class _LastActivity extends ConsumerWidget {
  const _LastActivity({required this.onSeeAll});
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final activityAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                'Last activity',
                style: AppTextStyles.labelMedium.copyWith(
                  color: col.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              _SeeAllLink(onTap: onSeeAll),
            ],
          ),
        ),
        Expanded(
          child: activityAsync.when(
            loading: () => const _ActivityCard(child: _ActivityEmpty(text: 'Loading…')),
            error: (_, _) =>
                const _ActivityCard(child: _ActivityEmpty(text: 'Could not load activity')),
            data: (items) {
              if (items.isEmpty) {
                return const _ActivityCard(
                  child: _ActivityEmpty(
                    text: 'No activity yet',
                    subtitle: 'Your latest transaction will appear here',
                  ),
                );
              }
              final visible = items.take(4).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < visible.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _ActivityCard(
                      onTap: onSeeAll,
                      child: _ActivityTile(tx: visible[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SeeAllLink extends StatefulWidget {
  const _SeeAllLink({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SeeAllLink> createState() => _SeeAllLinkState();
}

class _SeeAllLinkState extends State<_SeeAllLink> {
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
          'See all',
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: col.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}

class _ActivityEmpty extends StatelessWidget {
  const _ActivityEmpty({required this.text, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: col.textSecondary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall.copyWith(
              color: col.textDisabled,
              fontSize: 11.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.tx});
  final Transaction tx;

  ({IconData icon, Color tint, String title, String subtitle, String trailing, Color trailingColor})
  _resolve(BuildContext context) {
    final col = context.colors;

    if (tx.isSwap) {
      final inAmt = formatAmount(tx.tokenInValue);
      final outAmt = formatAmount(tx.tokenOutValue);
      return (
        icon: Icons.swap_horiz_rounded,
        tint: col.primary,
        title: 'Swap completed',
        subtitle: '$inAmt ${tx.tokenInSym} → $outAmt ${tx.tokenOutSym}',
        trailing: '+$outAmt ${tx.tokenOutSym}',
        trailingColor: col.success,
      );
    }

    final amt = formatAmount(tx.value);
    if (tx.isIncoming) {
      return (
        icon: Icons.arrow_downward_rounded,
        tint: col.success,
        title: 'Received',
        subtitle: 'From ${_short(tx.from)}',
        trailing: '+$amt ${tx.asset}',
        trailingColor: col.success,
      );
    }
    return (
      icon: Icons.arrow_upward_rounded,
      tint: col.warning,
      title: 'Sent',
      subtitle: 'To ${_short(tx.to)}',
      trailing: '-$amt ${tx.asset}',
      trailingColor: col.textPrimary,
    );
  }

  String _short(String addr) {
    if (addr.length < 12) return addr;
    return '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final r = _resolve(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: r.tint.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(r.icon, size: 18, color: r.tint),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: col.textPrimary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                r.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: col.textSecondary,
                  fontSize: 11.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaskableText(
                  r.trailing,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: r.trailingColor,
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 14, color: col.textDisabled),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              timeAgo(tx.blockTime),
              style: AppTextStyles.bodySmall.copyWith(
                color: col.textDisabled,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
