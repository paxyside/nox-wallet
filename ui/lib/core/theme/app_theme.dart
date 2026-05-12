import 'package:flutter/material.dart';
import 'package:nox/core/theme/app_color_scheme.dart';
import 'package:nox/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build(AppColorScheme c) {
    final isDark = c.background.computeLuminance() < 0.1;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: c.primary,
        onPrimary: Colors.white,
        secondary: c.primaryLight,
        onSecondary: Colors.white,
        error: c.error,
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: c.textPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: c.textPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: c.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: c.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: c.textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: c.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Inputs deliberately don't have their own background fill — every
        // text field in the app lives inside a card (surface / surfaceHigh)
        // that already provides the surface. A second fillColor produced a
        // darker rectangle inside the card on every input, which read as
        // "two boxes stacked" and obviously not what we want.
        filled: false,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Text-selection highlight — without an override Material draws an
      // opaque dark block under the selection that, in our dark theme, looks
      // exactly like a "second background" inside the field. A soft
      // primary-tinted selection blends in instead of stamping a rectangle.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.30),
        selectionHandleColor: c.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
    );
  }

  static ThemeData get dark => build(AppColorScheme.dark);
  static ThemeData get light => build(AppColorScheme.light);
}
