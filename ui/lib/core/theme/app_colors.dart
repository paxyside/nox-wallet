// Legacy static color constants — kept for isolated usages that don't have
// a BuildContext (e.g. const widget constructors, non-widget code).
// For all widget code prefer: context.colors.X
import 'package:flutter/material.dart';

export 'app_color_scheme.dart';

class AppColors {
  AppColors._();

  // Dark-theme values used as fallbacks in const contexts.
  static const background = Color(0xFF09090F);
  static const surface = Color(0xFF111118);
  static const surfaceHigh = Color(0xFF1A1A26);
  static const border = Color(0xFF242438);

  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);

  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const textPrimary = Color(0xFFEEEEFF);
  static const textSecondary = Color(0xFF8080A0);
  static const textDisabled = Color(0xFF3D3D58);
}
