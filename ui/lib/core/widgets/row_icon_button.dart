import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

/// Small icon-only button used in list rows (Tokens, Contacts, History,
/// Approvals) for in-row actions like Send / Copy / Edit / Open in
/// Etherscan / Delete.
///
/// Idle state is NEUTRAL — a quiet grey tile that doesn't compete for
/// attention when a screen has 10–20 rows visible. Hover shifts the
/// tile to a tinted accent (primary by default, error for `danger:
/// true`). One shared widget across screens so the visual language is
/// uniform.
class RowIconButton extends StatefulWidget {
  const RowIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
    this.size = 32,
    this.iconSize = 15,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  /// When true, the hover accent uses the theme's error/red instead of
  /// primary/purple. Use for destructive actions (Remove, Delete).
  /// Idle state stays neutral either way — danger only "lights up"
  /// when the user is actually pointing at it.
  final bool danger;

  /// Tile dimensions and inner icon size. Defaults match the
  /// Notification bell / Add-token affordances in Dashboard headers.
  final double size;
  final double iconSize;

  @override
  State<RowIconButton> createState() => _RowIconButtonState();
}

class _RowIconButtonState extends State<RowIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = widget.danger ? colors.error : colors.primary;

    final bg = _hovered ? accent.withValues(alpha: 0.14) : colors.surfaceHigh;
    final border = _hovered ? accent.withValues(alpha: 0.40) : colors.border;
    final iconColor = _hovered ? accent : colors.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
