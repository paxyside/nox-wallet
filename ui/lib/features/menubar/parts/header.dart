part of '../mini_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Headers — main popover header + sub-view header (with back arrow)
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final unread = ref.watch(unreadNotificationsProvider);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset(
            'assets/images/nox_logo.png',
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Text('Nox', style: AppTextStyles.h3.copyWith(color: col.textPrimary)),
        const Spacer(),
        _IconChip(
          icon: Icons.notifications_outlined,
          onTap: onOpenNotifications,
          badgeCount: unread,
        ),
      ],
    );
  }
}

class _IconChip extends StatefulWidget {
  const _IconChip({required this.icon, required this.onTap, this.badgeCount = 0});

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<_IconChip> createState() => _IconChipState();
}

class _IconChipState extends State<_IconChip> {
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _hovered ? col.surfaceHigh : col.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: col.border),
              ),
              child: Icon(
                widget.icon,
                size: 15,
                color: _hovered ? col.textPrimary : col.textSecondary,
              ),
            ),
            if (widget.badgeCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: _UnreadDot(count: widget.badgeCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final isPill = count > 9;
    return Container(
      height: 16,
      constraints: const BoxConstraints(minWidth: 16),
      padding: isPill ? const EdgeInsets.symmetric(horizontal: 4) : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: col.error,
        shape: isPill ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isPill ? BorderRadius.circular(8) : null,
        border: Border.all(color: col.background, width: 1.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _SubviewHeader extends StatelessWidget {
  const _SubviewHeader({
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Row(
      children: [
        _BackChip(onTap: onBack),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.h3.copyWith(color: col.textPrimary)),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _BackChip extends StatefulWidget {
  const _BackChip({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackChip> createState() => _BackChipState();
}

class _BackChipState extends State<_BackChip> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered ? col.surfaceHigh : col.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: col.border),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 16,
            color: _hovered ? col.textPrimary : col.textSecondary,
          ),
        ),
      ),
    );
  }
}
