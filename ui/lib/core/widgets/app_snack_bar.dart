import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nox/core/router/router.dart' show AppShell;

import 'package:nox/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Unified SnackBar helper
//
// Always floating, always rounded, colour-coded by intent.
// Usage:
//   AppSnackBar.success(context, 'Contact saved.');
//   AppSnackBar.error(context, 'Something went wrong.');
//   AppSnackBar.info(context, 'Address copied.');
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppSnackBar {
  /// Wired to the content-area [ScaffoldMessenger] in [AppShell].
  /// Using a key ensures snackbars are scoped to the content pane even when
  /// called from dialogs (which live in the root navigator's overlay and would
  /// otherwise resolve the root-level ScaffoldMessenger).
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void info(BuildContext context, String message) => _show(context, message, _Kind.info);

  static void success(BuildContext context, String message) =>
      _show(context, message, _Kind.success);

  static void error(BuildContext context, String message) => _show(context, message, _Kind.error);

  /// Success snackbar with a "View on Etherscan" action button that opens
  /// `https://etherscan.io/tx/<txHash>` in the default browser. Tapping the
  /// action also dismisses the snackbar (default Material would leave it).
  static void successWithLink(BuildContext context, String message, String txHash) => _show(
    context,
    message,
    _Kind.success,
    actionLabel: 'View on Etherscan',
    onAction: () {
      unawaited(launchUrl(Uri.parse('https://etherscan.io/tx/$txHash')));
      messengerKey.currentState?.hideCurrentSnackBar();
    },
  );
}

// ── internals ────────────────────────────────────────────────────────────────

enum _Kind { info, success, error }

void _show(
  BuildContext context,
  String message,
  _Kind kind, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final colors = context.colors;

  final (bg, fg, icon) = switch (kind) {
    _Kind.info => (const Color(0xFF2A2A3E), colors.textPrimary, Icons.info_outline_rounded),
    _Kind.success => (colors.success, Colors.white, Icons.check_circle_outline_rounded),
    _Kind.error => (colors.error, Colors.white, Icons.error_outline_rounded),
  };

  final duration = Duration(seconds: actionLabel != null ? 4 : 3);

  // Prefer the content-area messenger (keyed) so snackbars never bleed over
  // the sidebar — including when called from dialogs in the root overlay.
  (AppSnackBar.messengerKey.currentState ?? ScaffoldMessenger.of(context))
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 16, color: fg.withValues(alpha: 0.85)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, textColor: fg, onPressed: onAction)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withValues(alpha: kind == _Kind.info ? 0.08 : 0.0)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 4,
      ),
    );

  // Belt-and-suspenders auto-dismiss. SnackBar's built-in timer occasionally
  // gets paused/skipped on desktop (especially when the action button is
  // hovered). A manual timer guarantees the bar disappears when its time is up.
  Timer(duration + const Duration(milliseconds: 50), () {
    AppSnackBar.messengerKey.currentState?.hideCurrentSnackBar();
  });
}
