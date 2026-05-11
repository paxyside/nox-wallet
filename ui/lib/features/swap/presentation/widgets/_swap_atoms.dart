import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Percentage / MAX button
// ---------------------------------------------------------------------------

class PctBtn extends StatefulWidget {
  const PctBtn({
    required this.label,
    required this.onTap,
    this.isMax = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isMax;

  @override
  State<PctBtn> createState() => _PctBtnState();
}

class _PctBtnState extends State<PctBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isMax
                ? (_hovered && widget.onTap != null
                      ? context.colors.primary.withValues(alpha: 0.22)
                      : context.colors.primary.withValues(alpha: 0.12))
                : (_hovered && widget.onTap != null
                      ? context.colors.primary.withValues(alpha: 0.08)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isMax
                  ? context.colors.primary.withValues(alpha: 0.4)
                  : context.colors.border,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.onTap == null
                  ? context.colors.textDisabled
                  : widget.isMax
                  ? context.colors.primary
                  : context.colors.textSecondary,
              fontSize: 11,
              fontWeight: widget.isMax ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: widget.isMax ? 0.4 : 0,
            ),
          ),
        ),
      ),
    );
  }
}
