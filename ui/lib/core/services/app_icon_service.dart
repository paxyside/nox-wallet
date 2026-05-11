import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Syncs the macOS Dock icon with the current in-app theme.
///
/// Call [AppIconService.setTheme] whenever the theme mode changes.
/// The Swift side loads `AppIconDark` or `AppIconLight` from the asset catalog
/// and assigns it to `NSApp.applicationIconImage`.
abstract final class AppIconService {
  static const _channel = MethodChannel('nox/app_icon');

  /// Updates the Dock icon. Dark mode uses dark icon, light mode uses light.
  static Future<void> setTheme(ThemeMode mode) async {
    final isDark = mode != ThemeMode.light;
    try {
      await _channel.invokeMethod<void>('setTheme', isDark);
    } on Object catch (_) {
      // Non-macOS build or icon files not yet added — silently ignored.
    }
  }
}
