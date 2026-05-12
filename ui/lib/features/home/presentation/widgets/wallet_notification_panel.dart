import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/services/notification_copy.dart';
import 'package:nox/core/services/notification_history_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/utils/format.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';
import 'package:nox/features/notifications/presentation/widgets/notification_center.dart';

// Library file — split into `notification_panel/*.dart` so private
// widgets stay private (Dart privacy is per-library).
part 'notification_panel/header.dart';
part 'notification_panel/tabs.dart';
part 'notification_panel/list.dart';
part 'notification_panel/empty_footer.dart';
part 'notification_panel/notch.dart';

/// Popover that lists recent wallet events, anchored under the bell button via
/// `OverlayPortal` / `CompositedTransformFollower` in `wallet_header.dart`.
///
/// Layout:
///
///   1. Notch — small triangle pointing up at the bell.
///   2. Header — title + count pill, "Mark all as read", settings.
///   3. Tabs — All / Transactions / System.
///   4. List — rounded card-style tiles, one per event.
///   5. Footer — "View all history →" link.
class WalletNotificationPanel extends ConsumerStatefulWidget {
  const WalletNotificationPanel({required this.onClose, super.key});

  final VoidCallback onClose;

  static const double _width = 440;
  static const double _maxHeight = 540;
  static const double _notchSize = 10;

  @override
  ConsumerState<WalletNotificationPanel> createState() => _WalletNotificationPanelState();
}

enum _Tab { all, transactions, system }

class _WalletNotificationPanelState extends ConsumerState<WalletNotificationPanel> {
  _Tab _selected = _Tab.all;

  bool _matchesTab(WalletEvent e, _Tab tab) {
    switch (tab) {
      case _Tab.all:
        return true;
      case _Tab.transactions:
        return e.kind == WalletEventKind.transaction;
      case _Tab.system:
        return e.kind == WalletEventKind.gasAlert || e.kind == WalletEventKind.lowBalance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Watch the provider directly so live events / hydration reach the
    // open popover. The `widget.events` param is now just a starting
    // snapshot for the very first frame (kept for API stability) — the
    // ref.watch below supersedes it on every rebuild.
    final events = ref.watch(notificationHistoryProvider);
    final unreadCount = events.where((e) => !e.isRead).length;

    final filtered = events.where((e) => _matchesTab(e, _selected)).toList();

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: WalletNotificationPanel._width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Notch pointing at the bell ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: CustomPaint(
                size: const Size(
                  WalletNotificationPanel._notchSize * 2,
                  WalletNotificationPanel._notchSize,
                ),
                painter: _NotchPainter(fill: colors.surfaceHigh, stroke: colors.border),
              ),
            ),

            // ── Card ───────────────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: WalletNotificationPanel._maxHeight),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.04),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(
                        count: unreadCount,
                        onMarkAllRead: unreadCount == 0
                            ? null
                            : () => unawaited(
                                ref.read(notificationHistoryProvider.notifier).markAllRead(),
                              ),
                      ),
                      Divider(height: 1, color: colors.border),
                      _TabBar(selected: _selected, onChanged: (t) => setState(() => _selected = t)),
                      Divider(height: 1, color: colors.border),
                      Flexible(
                        child: filtered.isEmpty
                            ? _EmptyState(tab: _selected)
                            : _List(events: filtered),
                      ),
                      Divider(height: 1, color: colors.border),
                      _Footer(
                        onViewAll: () {
                          widget.onClose();
                          unawaited(showNotificationCenter(context));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
