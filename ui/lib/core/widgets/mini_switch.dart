import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

/// Compact themed switch — replaces Material's `Switch.adaptive` for
/// settings rows app-wide. The stock one is too large and uses
/// Material colours that clash with our palette in both themes; this
/// draws its own track + thumb in the app's primary / border colours.
///
/// Originally lived as `_MiniSwitch` inside `settings_screen.dart`;
/// extracted to `core/widgets` so the Notification settings panel and
/// any future toggle surfaces can pull it in instead of re-rolling the
/// same primitive.
class MiniSwitch extends StatelessWidget {
  const MiniSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _trackWidth = 34.0;
  static const _trackHeight = 20.0;
  static const _thumbSize = 14.0;
  static const _padding = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trackOn = colors.primary;
    final trackOff = colors.surfaceHigh;
    final borderOn = colors.primary.withValues(alpha: 0.6);
    final borderOff = colors.border;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: _trackWidth,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: value ? trackOn : trackOff,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            border: Border.all(color: value ? borderOn : borderOff, width: 1),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: value ? _trackWidth - _thumbSize - _padding - 2 : _padding - 1,
                top: (_trackHeight - _thumbSize) / 2 - 1,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : colors.textSecondary,
                    shape: BoxShape.circle,
                    boxShadow: value
                        ? [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 4)]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
