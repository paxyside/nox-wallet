import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

/// Shows a right-edge sliding drawer — the in-app counterpart of macOS
/// Inspector panels. Used for per-item detail views (Token details,
/// Contact details, etc.) where opening a full new screen would be
/// overkill but inline expansion bloats list-row heights.
///
/// The drawer slides in from the right with a darkened backdrop;
/// tapping the backdrop or pressing Escape dismisses it.
///
/// Implementation note: built on `showGeneralDialog` rather than a
/// custom Overlay because the framework already gives us a focus trap
/// and barrier-dismiss for free, and pushed routes are easy to
/// `Navigator.pop` from inside the content widget.
Future<T?> showRightDrawer<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
  double width = 380,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    barrierLabel: 'Close',
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, secondaryAnim) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: builder(ctx),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      // SlideTransition from off-screen-right (Offset(1, 0)) to anchored
      // (Offset.zero). Curve matches the segmented-control sliders and
      // other primary animations so the in-app motion feels uniform.
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

/// Standard chrome for drawer contents — a panel with the surface fill,
/// left border (where the drawer meets the underlying content), and
/// scrollable body. Callers compose `RightDrawerScaffold(...)` and pass
/// header/body slots so the visual frame is identical across drawers.
class RightDrawerScaffold extends StatelessWidget {
  const RightDrawerScaffold({
    required this.header,
    required this.body,
    this.scrollable = true,
    super.key,
  });

  final Widget header;

  /// Body slot — typically a Column of detail sections.
  final Widget body;

  /// When true (default), the body lives inside a SingleChildScrollView so
  /// arbitrarily-tall content gets a scrollbar. Set false for drawers
  /// designed to fit the viewport — e.g. the Token details drawer, which
  /// uses collapsible dropdowns so its on-screen height stays bounded and
  /// the appearance of a scrollbar would imply hidden content.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    const padding = EdgeInsets.fromLTRB(20, 14, 20, 16);
    return Container(
      decoration: BoxDecoration(
        color: col.surface,
        border: Border(left: BorderSide(color: col.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Divider(height: 1, color: col.border),
          Expanded(
            child: scrollable
                ? SingleChildScrollView(padding: padding, child: body)
                : Padding(padding: padding, child: body),
          ),
        ],
      ),
    );
  }
}
