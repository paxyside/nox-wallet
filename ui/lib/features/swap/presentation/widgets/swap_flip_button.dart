import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Flip button
// ---------------------------------------------------------------------------

class SwapFlipButton extends StatefulWidget {
  const SwapFlipButton({this.onTap, super.key});
  final VoidCallback? onTap;

  @override
  State<SwapFlipButton> createState() => _SwapFlipButtonState();
}

class _SwapFlipButtonState extends State<SwapFlipButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final canTap = widget.onTap != null;
    // Was a solid primary circle that read too loud sitting between
    // the PAY and RECEIVE cards. Neutral tile by default + primary
    // tint on hover follows the same icon-button rhythm used in
    // Settings / Dashboard rows.
    final bg = (_hovered && canTap) ? col.primary.withValues(alpha: 0.14) : col.surfaceHigh;
    final borderColor = (_hovered && canTap) ? col.primary.withValues(alpha: 0.40) : col.border;
    final iconColor = (_hovered && canTap) ? col.primary : col.textSecondary;

    return MouseRegion(
      cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Center(child: Icon(Icons.swap_vert_rounded, size: 16, color: iconColor)),
        ),
      ),
    );
  }
}
