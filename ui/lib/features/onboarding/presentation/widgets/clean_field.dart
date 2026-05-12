import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Clean single-line field (EditableText — no platform chrome)
// ─────────────────────────────────────────────────────────────────────────────

class CleanField extends StatefulWidget {
  const CleanField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.hasError = false,
    this.errorText,
    this.mono = false,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool hasError;
  final String? errorText;
  final bool mono;

  @override
  State<CleanField> createState() => _CleanFieldState();
}

class _CleanFieldState extends State<CleanField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? context.colors.error
        : _focused
        ? context.colors.primary
        : context.colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            onTap: () => widget.focusNode.requestFocus(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: _focused ? 1.5 : 1.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Stack(
                children: [
                  if (widget.controller.text.isEmpty)
                    Text(
                      widget.hint,
                      style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textDisabled),
                    ),
                  EditableText(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    style: widget.mono
                        ? TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: context.colors.textPrimary,
                          )
                        : AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                    cursorColor: context.colors.primary,
                    backgroundCursorColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.hasError && widget.errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
          ),
        ],
      ],
    );
  }
}
