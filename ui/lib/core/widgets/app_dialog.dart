import 'package:flutter/material.dart';

/// App-wide replacement for `showDialog` that anchors the modal to the
/// content area's Navigator instead of the root one.
///
/// `showDialog` defaults to `useRootNavigator: true`, so the barrier and
/// the centered child cover the whole window — including the sidebar on
/// the left. That makes every dialog appear visually shifted right.
///
/// `go_router.ShellRoute` already provisions an inner Navigator for
/// child routes; passing `useRootNavigator: false` makes the dialog use
/// that one. The barrier and child are then constrained to the content
/// area, so modals center where the user expects them to.
///
/// Other knobs we standardise here:
///   - `barrierDismissible` defaults to true (old behaviour) but can be
///     opted out for must-acknowledge dialogs (Send/Swap result modals).
///   - `barrierColor` left at theme default.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool rootOverlay = false,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: rootOverlay,
  );
}
