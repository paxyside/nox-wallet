import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';

void showErrorSnackBar(BuildContext context, String message) => AppSnackBar.error(context, message);

class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    required this.controller,
    required this.label,
    required this.hint,
    super.key,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        filled: false,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.4),
          foregroundColor: context.colors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.colors.textPrimary,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
              ),
      ),
    );
  }
}
