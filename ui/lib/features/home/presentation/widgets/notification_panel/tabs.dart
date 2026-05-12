part of '../wallet_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar — pill segmented control
// ─────────────────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selected, required this.onChanged});

  final _Tab selected;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          for (final t in _Tab.values) ...[
            _TabPill(
              label: switch (t) {
                _Tab.all => 'All',
                _Tab.transactions => 'Transactions',
                _Tab.system => 'System',
              },
              isSelected: t == selected,
              onTap: () => onChanged(t),
            ),
            if (t != _Tab.values.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _TabPill extends StatefulWidget {
  const _TabPill({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_TabPill> createState() => _TabPillState();
}

class _TabPillState extends State<_TabPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = widget.isSelected
        ? colors.primaryLight
        : _hovered
        ? colors.textPrimary
        : colors.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isSelected ? colors.primary.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? colors.primary.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
