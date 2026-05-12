import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/features/home/domain/home_usecase.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:nox/features/home/presentation/widgets/action_buttons.dart';
import 'package:nox/features/home/presentation/widgets/portfolio_chart.dart';
import 'package:nox/features/home/presentation/widgets/token_list.dart';
import 'package:nox/features/home/presentation/widgets/wallet_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _HomeContent(ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content
// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeDataProvider);

    return homeAsync.when(
      loading: () => const _LoadingSkeleton(),
      error: (err, _) =>
          _ErrorState(message: errorMessage(err), onRetry: () => ref.invalidate(homeDataProvider)),
      data: (state) =>
          _LoadedContent(state: state, onRefresh: () => ref.invalidate(homeDataProvider)),
    );
  }
}

// Loaded state

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.state, required this.onRefresh});

  final HomeState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    // Fixed window (1100×720) — the dashboard must fit without a scrollbar.
    // The bottom Row uses Expanded so it claims whatever vertical space is
    // left after the header and the action buttons.
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WalletHeader(
            walletInfo: state.walletInfo,
            balanceData: state.balanceData,
            gasStats: state.gasStats,
          ),
          const SizedBox(height: 16),
          ActionButtons(address: state.walletInfo.address),
          const SizedBox(height: 20),
          // Two-column: Tokens + Portfolio. Expanded gives the row a finite
          // height (= remaining viewport) — no IntrinsicHeight needed and
          // children won't try to grow past the window.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: TokenList(balanceData: state.balanceData)),
                const SizedBox(width: 16),
                Expanded(child: PortfolioChart(balanceData: state.balanceData)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Loading skeleton

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(height: 140, borderRadius: 16),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 68, borderRadius: 12)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 68, borderRadius: 12)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 68, borderRadius: 12)),
            ],
          ),
          SizedBox(height: 28),
          _SkeletonBox(height: 24, width: 80, borderRadius: 6),
          SizedBox(height: 12),
          _SkeletonBox(height: 64, borderRadius: 12),
          SizedBox(height: 8),
          _SkeletonBox(height: 64, borderRadius: 12),
          SizedBox(height: 8),
          _SkeletonBox(height: 64, borderRadius: 12),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.height, required this.borderRadius, this.width});

  final double height;
  final double borderRadius;
  final double? width;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    unawaited(_ctrl.repeat(reverse: true));
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: context.colors.surface.withAlpha((_anim.value * 255).round()),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: context.colors.border),
        ),
      ),
    );
  }
}

// Error state

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load wallet data',
              style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
