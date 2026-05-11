import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/contacts/domain/contact.dart';

class ContactListTile extends StatefulWidget {
  const ContactListTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Contact contact;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<ContactListTile> createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  bool _hovered = false;

  String get _truncatedAddress {
    final addr = widget.contact.address;
    if (addr.length <= 14) return addr;
    return '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';
  }

  String get _avatarLetter {
    final name = widget.contact.name.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? context.colors.primary.withValues(alpha: 0.18)
                : _hovered
                ? context.colors.surfaceHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? context.colors.primary.withValues(alpha: 0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              _Avatar(letter: _avatarLetter),
              const SizedBox(width: 12),
              // Name + address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _truncatedAddress,
                      style: AppTextStyles.monoSmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Hover actions
              if (_hovered || selected) ...[
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: widget.onEdit,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 2),
                _IconAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  onTap: widget.onDelete,
                  color: context.colors.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  // Pick a deterministic color from the letter's code unit.
  Color get _bg {
    const colors = [
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFF0984E3),
      Color(0xFFE17055),
      Color(0xFFD63031),
      Color(0xFF6AB04C),
      Color(0xFFE84393),
    ];
    final idx = letter.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _bg.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _bg.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _bg,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
