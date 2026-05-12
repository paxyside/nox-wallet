import 'package:flutter/material.dart';

/// Base text styles — no color baked in.
/// Use `context.colors.textPrimary` / `context.colors.textSecondary` for color.
class AppTextStyles {
  AppTextStyles._();

  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  static const mono = TextStyle(fontSize: 13, fontFamily: 'monospace');
  static const monoSmall = TextStyle(fontSize: 11, fontFamily: 'monospace');
}
