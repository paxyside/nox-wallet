import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mini icon button (Send / Swap / Details)
// ─────────────────────────────────────────────────────────────────────────────

class TokenMiniBtn extends StatefulWidget {
  const TokenMiniBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.rotated = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final bool rotated;

  @override
  State<TokenMiniBtn> createState() => _TokenMiniBtnState();
}

class _TokenMiniBtnState extends State<TokenMiniBtn> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;
    final c = widget.color;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: active
                      ? [
                          c.withValues(alpha: _pressed ? 0.22 : 0.15),
                          c.withValues(alpha: _pressed ? 0.10 : 0.06),
                        ]
                      : [
                          c.withValues(alpha: 0.08),
                          c.withValues(alpha: 0.08),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active
                      ? c.withValues(alpha: _pressed ? 0.65 : 0.45)
                      : c.withValues(alpha: 0.15),
                  width: active ? 1.5 : 1.0,
                ),
                boxShadow: (_hovered && !_pressed)
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedRotation(
                  turns: widget.rotated ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(widget.icon, size: 17, color: c),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
