part of '../mini_widget.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onDashboard, required this.onSend, required this.onSwap});

  final VoidCallback onDashboard;
  final VoidCallback onSend;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    // No outer wrapper card — each action is a standalone outlined
    // tile (matches the dashboard ActionButtons row). Wrapping a
    // group of bordered cards in another bordered card stacked two
    // visual frames over each tile and read as "container in a
    // container" rather than a row of buttons.
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: onDashboard,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.arrow_upward_rounded,
            label: 'Send',
            onTap: onSend,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.swap_horiz_rounded,
            label: 'Swap',
            onTap: onSwap,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatefulWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    // Matches the dashboard ActionButtons aesthetic: a neutral icon
    // tile inside an outlined card, primary tint promoted only on
    // hover. The old solid-gradient discs shouted at the user every
    // time the popover opened — fine for a one-off marketing screen,
    // but jarring in a quick-action surface the user opens a dozen
    // times a day.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        // Borders + textPrimary at rest — same readability contract
        // as the dashboard ActionButtons. The previous version made
        // rest-state borders transparent, which dropped the tiles
        // visually below "clickable" and read as decoration.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? col.surfaceHigh : col.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? col.primary.withValues(alpha: 0.4) : col.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: col.textSecondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: col.textSecondary.withValues(alpha: 0.22)),
                ),
                child: Icon(
                  widget.icon,
                  size: 17,
                  color: _hovered ? col.primaryLight : col.textSecondary,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: col.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
