import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/services/notification_copy.dart';
import 'package:nox/core/services/notification_history_provider.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/state/privacy_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/theme/theme_provider.dart';
import 'package:nox/core/utils/format.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/history/domain/transaction.dart';
import 'package:nox/features/home/domain/home_usecase.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:nox/features/home/presentation/providers/recent_activity_provider.dart';

// Library file — split into `parts/*.dart` so the mini popover's
// widgets stay private (Dart privacy is per-library, not per-file).
// Each part covers one feature area; the shell + view-switcher live
// here so the navigation graph is in one place.
part 'parts/views.dart';
part 'parts/header.dart';
part 'parts/footer.dart';
part 'parts/balance.dart';
part 'parts/quick_actions.dart';
part 'parts/activity.dart';
part 'parts/notifications.dart';
part 'parts/settings.dart';

/// Wall-clock timestamp of the last successful home-data resolution. Used by
/// the network chip dialog to render a "Updated Ns ago" footer. Updated
/// lazily by `MiniWidget.build` via `ref.listen`; null until the first
/// successful fetch in this session.
final homeDataRefreshedAtProvider = StateProvider<DateTime?>((ref) => null);

/// Sub-view shown inside the mini popover. Notifications and settings render
/// in-place rather than expanding the full window — the popover is intended
/// to be glanceable and the user shouldn't lose their tray-anchored context
/// just to mark a notification read or flip a theme toggle.
enum _MiniView { home, notifications, settings }

/// Compact menu-bar popover. Rendered inside a 380×660 window that drops
/// from the macOS tray icon. Quick actions exit mini mode and forward the
/// caller to a route in the full app via `onOpenAt` rather than
/// `context.go(...)`, since this widget lives in its own MaterialApp scope
/// (no router).
class MiniWidget extends ConsumerStatefulWidget {
  const MiniWidget({
    required this.onOpenAt,
    required this.onOpenNotificationCenter,
    required this.onQuit,
    super.key,
  });

  /// Exit mini mode and navigate the full window to the given route.
  final void Function(String route) onOpenAt;

  /// Exit mini mode and pop the notification center overlay above the
  /// full window. The mini popover has its own MaterialApp scope so it
  /// can't host a route-anchored dialog itself; the parent (main.dart)
  /// expands the window first and then calls `showNotificationCenter`.
  final VoidCallback onOpenNotificationCenter;

  /// Quit the application (bypasses the tray-hide intercept).
  final VoidCallback onQuit;

  @override
  ConsumerState<MiniWidget> createState() => _MiniWidgetState();
}

class _MiniWidgetState extends ConsumerState<MiniWidget> {
  _MiniView _view = _MiniView.home;

  void _setView(_MiniView v) {
    if (_view == v) return;
    setState(() => _view = v);
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    ref.listen<AsyncValue<HomeState>>(homeDataProvider, (prev, next) {
      if (next is AsyncData<HomeState>) {
        ref.read(homeDataRefreshedAtProvider.notifier).state = DateTime.now();
      }
    });

    return Scaffold(
      backgroundColor: col.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: switch (_view) {
          _MiniView.home => _HomeView(
            onOpenAt: widget.onOpenAt,
            onQuit: widget.onQuit,
            onOpenNotifications: () => _setView(_MiniView.notifications),
            onOpenSettings: () => _setView(_MiniView.settings),
          ),
          _MiniView.notifications => _NotificationsView(
            onBack: () => _setView(_MiniView.home),
            onViewAll: widget.onOpenNotificationCenter,
            onQuit: widget.onQuit,
          ),
          _MiniView.settings => _SettingsView(
            onBack: () => _setView(_MiniView.home),
            onOpenFullSettings: () => widget.onOpenAt(Routes.settings),
            onQuit: widget.onQuit,
          ),
        },
      ),
    );
  }
}
