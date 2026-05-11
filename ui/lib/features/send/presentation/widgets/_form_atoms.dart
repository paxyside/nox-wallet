import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      message,
      style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
    ),
  );
}

class IconBtn extends StatelessWidget {
  const IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    super.key,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color:
              color ?? (onTap == null ? context.colors.textDisabled : context.colors.textSecondary),
        ),
      ),
    ),
  );
}
