part of '../notification_center.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar — All / Transactions / System / Unread (with count pill)
// ─────────────────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.selected,
    required this.unread,
    required this.onChanged,
  });

  final _Tab selected;
  final int unread;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          for (final t in _Tab.values) ...[
            _TabPill(
              label: switch (t) {
                _Tab.all => 'All',
                _Tab.transactions => 'Transactions',
                _Tab.system => 'System',
                _Tab.unread => 'Unread',
              },
              count: t == _Tab.unread ? unread : null,
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
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  State<_TabPill> createState() => _TabPillState();
}

class _TabPillState extends State<_TabPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final selected = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? col.primary.withValues(alpha: 0.18)
                : (_hovered ? col.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? col.primary.withValues(alpha: 0.5) : col.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? col.primaryLight : col.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: col.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
