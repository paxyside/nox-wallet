part of '../mini_widget.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onDashboard, required this.onSend, required this.onSwap});

  final VoidCallback onDashboard;
  final VoidCallback onSend;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: col.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(icon: Icons.dashboard_rounded, label: 'Dashboard', onTap: onDashboard),
          _QuickAction(icon: Icons.arrow_upward_rounded, label: 'Send', onTap: onSend),
          _QuickAction(icon: Icons.swap_horiz_rounded, label: 'Swap', onTap: onSwap),
        ],
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [col.primaryLight, col.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: col.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(widget.icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 7),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: col.textPrimary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
