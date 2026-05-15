part of '../mini_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions — three icon+label columns, no card chrome.
//
// Earlier iterations wrapped this row in an outlined card AND gave
// each tile its own border, stacking two visual frames over every
// action. Real estate in the menubar popover is precious; every
// pixel spent on chrome is a pixel not spent on the activity feed.
// Now each action is a minimal `icon-tile + label` stack with a
// subtle hover state on the tile only — saves ~50px of vertical
// space, surfaces one extra activity row underneath.
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onDashboard, required this.onSend, required this.onSwap});

  final VoidCallback onDashboard;
  final VoidCallback onSend;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: onDashboard,
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Icons.arrow_upward_rounded,
            label: 'Send',
            onTap: onSend,
          ),
        ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon tile carries the entire hover signal — fill
              // shifts to surfaceHigh + primary border + icon goes
              // primary. Label stays textPrimary at rest (so the
              // action reads as clickable without hovering) and only
              // brightens slightly on hover, which is enough motion.
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hovered ? col.surfaceHigh : col.textSecondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: _hovered
                        ? col.primary.withValues(alpha: 0.45)
                        : col.textSecondary.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 19,
                  color: _hovered ? col.primaryLight : col.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: col.textPrimary,
                  fontSize: 11.5,
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
