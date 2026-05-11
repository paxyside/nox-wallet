import 'package:flutter/material.dart';

/// Semantic color tokens for both dark and light themes.
/// Access via: `context.colors.background`
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.primary,
    required this.primaryLight,
    required this.success,
    required this.error,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color primary;
  final Color primaryLight;
  final Color success;
  final Color error;
  final Color warning;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // ---------------------------------------------------------------------------
  // Palettes
  // ---------------------------------------------------------------------------

  /// Deep indigo-dark — subtle blue/purple undertone throughout.
  static const dark = AppColorScheme(
    background: Color(0xFF09090F),
    surface: Color(0xFF111118),
    surfaceHigh: Color(0xFF1A1A26),
    border: Color(0xFF242438),
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF818CF8),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    textPrimary: Color(0xFFEEEEFF),
    textSecondary: Color(0xFF8080A0),
    textDisabled: Color(0xFF3D3D58),
  );

  /// Neutral light — clean white/gray base.
  static const light = AppColorScheme(
    background: Color(0xFFF0F0F5),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF5F5F8),
    border: Color(0xFFE2E2E8),
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF818CF8),
    success: Color(0xFF16A34A),
    error: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    textPrimary: Color(0xFF0F0F14),
    textSecondary: Color(0xFF60607A),
    textDisabled: Color(0xFFAAAAAC),
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension overrides
  // ---------------------------------------------------------------------------

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? border,
    Color? primary,
    Color? primaryLight,
    Color? success,
    Color? error,
    Color? warning,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
  }) => AppColorScheme(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceHigh: surfaceHigh ?? this.surfaceHigh,
    border: border ?? this.border,
    primary: primary ?? this.primary,
    primaryLight: primaryLight ?? this.primaryLight,
    success: success ?? this.success,
    error: error ?? this.error,
    warning: warning ?? this.warning,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// BuildContext shortcut
// ---------------------------------------------------------------------------

extension AppColorsX on BuildContext {
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
}
