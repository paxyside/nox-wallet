part of '../notification_center.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Header — title + unread pill + Mark all + Clear all + settings + close
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.unread,
    required this.settingsActive,
    required this.onToggleSettings,
    required this.onMarkAllRead,
    required this.onClearAll,
    required this.onClose,
  });

  final int unread;
  final bool settingsActive;
  final VoidCallback onToggleSettings;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined, size: 20, color: col.textPrimary),
          const SizedBox(width: 10),
          Text(
            'Notification center',
            style: AppTextStyles.h2.copyWith(color: col.textPrimary, fontSize: 17),
          ),
          if (unread > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: col.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: col.primaryLight,
                ),
              ),
            ),
          ],
          const Spacer(),
          _HeaderAction(icon: Icons.done_all_rounded, label: 'Mark all read', onTap: onMarkAllRead),
          const SizedBox(width: 6),
          _HeaderAction(
            icon: Icons.delete_outline_rounded,
            label: 'Clear all',
            color: col.error,
            onTap: onClearAll,
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 18, color: col.border),
          const SizedBox(width: 10),
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            isActive: settingsActive,
            onTap: onToggleSettings,
            tooltip: 'Notification settings',
          ),
          const SizedBox(width: 4),
          _HeaderIconButton(icon: Icons.close_rounded, onTap: onClose, tooltip: 'Close'),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatefulWidget {
  const _HeaderAction({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<_HeaderAction> createState() => _HeaderActionState();
}

class _HeaderActionState extends State<_HeaderAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final disabled = widget.onTap == null;
    final base = widget.color ?? col.textSecondary;
    final color = disabled
        ? col.textDisabled
        : (_hovered ? (widget.color ?? col.textPrimary) : base);
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered && !disabled ? col.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isActive;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final btn = MouseRegion(
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
            color: widget.isActive
                ? col.primary.withValues(alpha: 0.18)
                : (_hovered ? col.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.isActive ? col.primaryLight : col.textSecondary,
          ),
        ),
      ),
    );
    final tooltip = widget.tooltip;
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }
}
