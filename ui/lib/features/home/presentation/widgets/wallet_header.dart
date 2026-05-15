import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/services/notification_history_provider.dart';
import 'package:nox/core/services/sync_status_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/formatters.dart';
import 'package:nox/core/widgets/copy_button.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/portfolio_summary.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/home/presentation/widgets/wallet_network_stats.dart';
import 'package:nox/features/home/presentation/widgets/wallet_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class WalletHeader extends StatelessWidget {
  const WalletHeader({
    required this.walletInfo,
    required this.balanceData,
    required this.gasStats,
    super.key,
  });

  final WalletInfo walletInfo;
  final BalanceData balanceData;
  final GasStats gasStats;

  String _truncatedAddress(String addr) {
    if (addr.length <= 14) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUsd = balanceData.ethUsdValue.isNotEmpty;
    final portfolio = computePortfolioSummary(balanceData.ethUsdValue, balanceData.tokens);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.surfaceHigh, context.colors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        // Allow children (notably the bell's unread badge) to render
        // outside the Stack's bounds; default Clip.hardEdge was cutting
        // the top-right corner of the badge against the card's rounded
        // edge.
        clipBehavior: Clip.none,
        children: [
          // ── Mesh particle background ────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(painter: _MeshPainter()),
            ),
          ),

          // ── Radial glow bottom-right ─────────────────────────────────────
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0x40 / 255),
                    context.colors.primary.withValues(alpha: 0x15 / 255),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          // Note: IntrinsicHeight here triggered a "RenderImage does not
          // implement computeDryBaseline" crash because the row contains
          // network images (TokenIcon via Image.network). Use natural sizing.
          Row(
            children: [
              // Left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet name (no edit icon)
                    Text(
                      walletInfo.label.isNotEmpty ? walletInfo.label : 'My Wallet',
                      style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    // Address + copy
                    Row(
                      children: [
                        Text(
                          _truncatedAddress(walletInfo.address),
                          style: AppTextStyles.mono.copyWith(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        CopyButton(
                          value: walletInfo.address,
                          successMessage: 'Address copied to clipboard.',
                          tooltip: 'Copy address',
                          size: 13,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Balance — headline is the wallet's TOTAL across
                    // every priced asset when more than one is priced
                    // (so the user sees their full bag, not just ETH).
                    // Falls back to ETH USD when ETH is the only
                    // priced asset. The detail row below pairs the
                    // native ETH amount with its USD value using a
                    // middle-dot separator — keeps "what you have"
                    // and "what it's worth" on a single tight line.
                    if (hasUsd) ...[
                      MaskableText(
                        portfolio != null
                            ? formatPortfolioTotal(portfolio.totalUsd)
                            : balanceData.ethUsdValue,
                        maskLength: 8,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          height: 1,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TokenIcon(symbol: 'ETH', logoUrl: balanceData.ethLogoUrl, size: 18),
                          const SizedBox(width: 6),
                          MaskableText(
                            // 4 decimals — sufficient for visual scan;
                            // 6 was too noisy under a $X.XX figure in
                            // the hero card. Full precision still lives
                            // on Send / Swap / History detail surfaces.
                            '${formatEth(balanceData.ethBalance, decimals: 4)} ETH · ${balanceData.ethUsdValue}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              // Lift from textSecondary toward textPrimary
                              // so the line doesn't read as disabled
                              // (textSecondary on dark theme = quite dim).
                              color: context.colors.textPrimary.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          TokenIcon(symbol: 'ETH', logoUrl: balanceData.ethLogoUrl, size: 32),
                          const SizedBox(width: 10),
                          MaskableText(
                            '${formatEth(balanceData.ethBalance)} ETH',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Right column — uses MainAxisSize.min + a fixed gap instead
              // of Spacer because the parent Row no longer enforces a height
              // (we removed IntrinsicHeight to avoid RenderImage crashes).
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ethereum badge + bell
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_EthereumBadge(), const SizedBox(width: 8), _NotificationBell()],
                  ),
                  const SizedBox(height: 36),
                  // Gas + Block chips
                  WalletNetworkStats(gasStats: gasStats, balanceData: balanceData),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ethereum badge — hoverable, shows sync times in tooltip
// ─────────────────────────────────────────────────────────────────────────────

class _EthereumBadge extends ConsumerStatefulWidget {
  @override
  ConsumerState<_EthereumBadge> createState() => _EthereumBadgeState();
}

class _EthereumBadgeState extends ConsumerState<_EthereumBadge> {
  bool _hovered = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-render every 5s so "X sec ago" stays fresh while tooltip is shown.
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_hovered && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static String _ago(DateTime? t) {
    if (t == null) return 'never';
    final secs = DateTime.now().difference(t).inSeconds;
    if (secs < 5) return 'just now';
    if (secs < 60) return '${secs}s ago';
    final mins = secs ~/ 60;
    if (mins < 60) return '${mins}m ago';
    return '${mins ~/ 60}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusNotifierProvider);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _hovered ? context.colors.surfaceHigh : context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: context.colors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Ethereum',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );

    return Tooltip(
      // Was: "Network  just now / Wallet  just now" — read as standalone
      // labels, not a "X was last synced Y ago" sentence. Spelling out
      // "last synced" removes the ambiguity for anyone hovering for the
      // first time.
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: 'Network last synced  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
          TextSpan(
            text: _ago(sync.networkSynced),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'Wallet last synced     ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
          TextSpan(
            text: _ago(sync.walletSynced),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      preferBelow: true,
      waitDuration: const Duration(milliseconds: 200),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: badge,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification bell — opens activity popover
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationBell extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<_NotificationBell> {
  bool _hovered = false;
  final _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _toggle(BuildContext context) {
    if (_entry != null) {
      _close();
      return;
    }
    _open(context);
  }

  void _open(BuildContext context) {
    // Read state now lives per-row server-side. The user marks events
    // read explicitly via the "Mark all as read" header action or by
    // tapping individual tiles in the notification center — opening
    // the bell no longer flips anything automatically.
    final entry = OverlayEntry(
      builder: (ctx) {
        // Full-screen catcher so an outside tap dismisses without
        // blocking the bell itself; the popover sits on top via the
        // CompositedTransformFollower anchored to `_link`.
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _close),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              // Anchor: bell's top-right corner. Offset: a small tail of
              // 10px below the button + nudge right so the panel's right
              // edge lines up with the bell (panel width 320, bell ≈ 30,
              // so panel.left = bell.right − 320 + 8).
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(8, 10),
              child: WalletNotificationPanel(onClose: _close),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(entry);
    _entry = entry;
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationsProvider);

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => _toggle(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _hovered ? context.colors.surfaceHigh : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 15,
                  color: _hovered ? context.colors.textPrimary : context.colors.textSecondary,
                ),
              ),
              // Unread badge — explicit Size, bright accent + halo so the
              // digit reads at a glance. Single-digit counts get a perfectly
              // round dot; ">9" stretches into a pill.
              if (unread > 0) Positioned(top: -6, right: -6, child: _Badge(count: unread)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bell unread badge
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPill = count > 9;

    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: isPill ? const EdgeInsets.symmetric(horizontal: 5) : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        shape: isPill ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isPill ? BorderRadius.circular(9) : null,
        boxShadow: [BoxShadow(color: colors.error.withValues(alpha: 0.5), blurRadius: 6)],
      ),
      child: Text(
        isPill ? '9+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mesh / particle painter
// ─────────────────────────────────────────────────────────────────────────────

class _MeshPainter extends CustomPainter {
  static final _rng = Random(42); // fixed seed → deterministic

  // Generate dots once
  static final List<Offset> _dots = List.generate(28, (_) {
    return Offset(_rng.nextDouble(), _rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dotColor = Color(0x306366F1);

    final dotPaint = Paint()..color = dotColor;

    final pts = _dots.map((d) => Offset(d.dx * size.width, d.dy * size.height)).toList();

    // Draw lines between close dots
    for (var i = 0; i < pts.length; i++) {
      for (var j = i + 1; j < pts.length; j++) {
        final dist = (pts[i] - pts[j]).distance;
        if (dist < size.width * 0.28) {
          final alpha = ((1 - dist / (size.width * 0.28)) * 0.25).clamp(0.0, 1.0);
          canvas.drawLine(
            pts[i],
            pts[j],
            Paint()
              ..color = const Color(0xFF6366F1).withValues(alpha: alpha)
              ..strokeWidth = 0.8,
          );
        }
      }
    }

    // Draw dots
    for (final p in pts) {
      canvas.drawCircle(p, 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
