import 'package:flutter/material.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// ThemedDropdown — single source of truth for select-style controls.
//
// The trigger is a pill that follows our palette in both themes: surface +
// border at rest, surfaceHigh + primary border on hover/open. The popup
// panel mirrors the trigger's width exactly, drops in just below it, and
// animates with a top-anchored scaleY + fade — mimicking Material's
// `showMenu` opening, which felt nicer than a pure fade in earlier prototypes.
//
// Usage:
//   ThemedDropdown<String>(
//     value: selected,
//     items: const [
//       ThemedDropdownItem(value: '', label: 'All Tokens'),
//       ThemedDropdownItem(value: 'USDC', label: 'USDC'),
//     ],
//     onChanged: (v) => ...,
//   )
//
// Pass `width` to override the trigger's intrinsic minimum (useful when the
// content varies in length and you want the pill to stay constant).
// ---------------------------------------------------------------------------

class ThemedDropdownItem<T> {
  const ThemedDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

class ThemedDropdown<T> extends StatefulWidget {
  const ThemedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.width = 132,
    this.leadingIcon,
  });

  final T value;
  final List<ThemedDropdownItem<T>> items;
  final ValueChanged<T> onChanged;

  /// Fixed width for the trigger pill (and consequently the popup panel).
  /// The default fits a label up to ~"15 minutes" comfortably.
  final double width;

  /// Optional icon shown on the leading side of the trigger pill.
  final IconData? leadingIcon;

  @override
  State<ThemedDropdown<T>> createState() => _ThemedDropdownState<T>();
}

class _ThemedDropdownState<T> extends State<ThemedDropdown<T>> {
  bool _hovered = false;
  bool _open = false;
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _show();
    }
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _open = false);
  }

  void _show() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Tap-outside dismisser
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: _AnimatedPanel<T>(
              width: size.width,
              items: widget.items,
              selected: widget.value,
              onPicked: (v) {
                widget.onChanged(v);
                _close();
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = _hovered || _open;
    final selected = widget.items.firstWhere(
      (i) => i.value == widget.value,
      orElse: () => widget.items.first,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active ? colors.surfaceHigh : colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? colors.primary.withValues(alpha: 0.5) : colors.border,
              ),
            ),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    selected.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 160),
                  turns: _open ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Popup panel with self-contained intro animation ────────────────────────

/// Wraps the static panel with a one-shot expand-from-top animation. Lives
/// inside the OverlayEntry so its own initState fires the moment the entry
/// mounts — no need to coordinate with a controller in the parent State,
/// which was fragile across hot reloads.
class _AnimatedPanel<T> extends StatefulWidget {
  const _AnimatedPanel({
    required this.width,
    required this.items,
    required this.selected,
    required this.onPicked,
  });

  final double width;
  final List<ThemedDropdownItem<T>> items;
  final T selected;
  final ValueChanged<T> onPicked;

  @override
  State<_AnimatedPanel<T>> createState() => _AnimatedPanelState<T>();
}

class _AnimatedPanelState<T> extends State<_AnimatedPanel<T>> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    // Schedule the transition for the next frame so AnimatedScale / Opacity
    // see a state change and tween instead of jumping straight to the
    // expanded state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      opacity: _shown ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        scale: _shown ? 1 : 0.92,
        child: _Panel<T>(
          width: widget.width,
          items: widget.items,
          selected: widget.selected,
          onPicked: widget.onPicked,
        ),
      ),
    );
  }
}

class _Panel<T> extends StatelessWidget {
  const _Panel({
    required this.width,
    required this.items,
    required this.selected,
    required this.onPicked,
  });

  final double width;
  final List<ThemedDropdownItem<T>> items;
  final T selected;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              _PanelItem<T>(
                label: item.label,
                isSelected: item.value == selected,
                onTap: () => onPicked(item.value),
              ),
          ],
        ),
      ),
    );
  }
}

class _PanelItem<T> extends StatefulWidget {
  const _PanelItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PanelItem<T>> createState() => _PanelItemState<T>();
}

class _PanelItemState<T> extends State<_PanelItem<T>> {
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
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _hovered ? colors.surfaceHigh : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: fg,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.check_rounded, size: 14, color: colors.primaryLight),
            ],
          ),
        ),
      ),
    );
  }
}
