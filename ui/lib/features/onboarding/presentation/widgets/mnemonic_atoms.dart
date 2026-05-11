import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 12 / 24 toggle
// ─────────────────────────────────────────────────────────────────────────────

class WordCountToggle extends StatelessWidget {
  const WordCountToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: '12', active: value == 12, onTap: () => onChanged(12)),
          const SizedBox(width: 2),
          _Pill(label: '24', active: value == 24, onTap: () => onChanged(24)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? context.colors.textPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paste button
// ─────────────────────────────────────────────────────────────────────────────

class PasteButton extends StatelessWidget {
  const PasteButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.content_paste_rounded,
            size: 13,
            color: context.colors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            'Paste',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clear button
// ─────────────────────────────────────────────────────────────────────────────

class ClearButton extends StatelessWidget {
  const ClearButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.clear_rounded,
            size: 13,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            'Clear',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
