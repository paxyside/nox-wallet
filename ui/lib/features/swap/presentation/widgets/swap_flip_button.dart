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
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered && widget.onTap != null
                ? context.colors.primaryLight
                : context.colors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.swap_vert_rounded, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
