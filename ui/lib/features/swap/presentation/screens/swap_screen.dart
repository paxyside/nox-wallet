import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/widgets/swap_confirm_dialog.dart';
import 'package:nox/features/swap/presentation/widgets/swap_form.dart';
import 'package:nox/features/swap/presentation/widgets/swap_gas_card.dart';

class SwapScreen extends ConsumerStatefulWidget {
  const SwapScreen({this.initialTokenInAddress, super.key});

  /// Pre-fills the PAY (input) side with this contract address right
  /// after mount. Drives the Swap quick-action from the Tokens screen.
  final String? initialTokenInAddress;

  @override
  ConsumerState<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends ConsumerState<SwapScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final wanted = widget.initialTokenInAddress;
    if (wanted == null || wanted.isEmpty) return;
    // Same Riverpod-from-initState rule as Send — defer via microtask.
    unawaited(
      Future.microtask(() {
        if (!mounted) return;
        ref.read(swapNotifierProvider.notifier).setTokenIn(wanted);
      }),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swapNotifierProvider);
    final notifier = ref.read(swapNotifierProvider.notifier);
    final assets = ref.watch(swappableAssetsProvider).valueOrNull ?? [];

    // Result dialog is owned by AppShell so the modal survives navigation
    // (mirrors the Send flow). No screen-level success listener here.

    // Auto-scroll the form to its bottom when the user picks Custom — the
    // expanded Priority/Max inputs would otherwise be tucked under the
    // pinned Preview button. Triggered on tier-change transitions.
    ref.listen<GasTier>(
      swapNotifierProvider.select((s) => s.gasTier),
      (prev, next) {
        if (prev != next && next == GasTier.custom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scroll.hasClients) return;
            unawaited(
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              ),
            );
          });
        }
      },
    );

    SwapAsset? assetFor(String address) {
      if (address.isEmpty) return null;
      try {
        return assets.firstWhere((a) => a.address == address);
      } on Object catch (_) {
        return null;
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Scrollable form area ───────────────────────────
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              controller: _scroll,
                              padding: const EdgeInsets.fromLTRB(28, 18, 28, 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header
                                  Text(
                                    'Swap',
                                    style: AppTextStyles.h2.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Exchange tokens using Uniswap V3 liquidity pools.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(
                                    height: 1,
                                    color: context.colors.border,
                                  ),
                                  const SizedBox(height: 12),

                                  // Form
                                  const SwapForm(),

                                  // Compact rate header + gas card. Full
                                  // breakdown (slippage, route, fee USD…)
                                  // moved into SwapConfirmDialog so the
                                  // form stays uncluttered.
                                  if (state.quote != null) ...[
                                    const SizedBox(height: 10),
                                    _RateBanner(
                                      quote: state.quote!,
                                      assetIn: assetFor(state.tokenIn),
                                      assetOut: assetFor(state.tokenOut),
                                      amountIn: state.amountIn,
                                      isRefreshing: state.status == SwapStatus.quoting,
                                    ),
                                    const SizedBox(height: 8),
                                    const SwapGasCard(),
                                  ],

                                  // Error banner
                                  if (state.errorMessage != null &&
                                      state.status == SwapStatus.failure) ...[
                                    const SizedBox(height: 10),
                                    _ErrorBanner(message: state.errorMessage!),
                                  ],

                                  // Success state has no inline banner — the
                                  // green snackbar with "View on Etherscan"
                                  // is the canonical success affordance.
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Action button pinned at bottom ─────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(height: 1, color: context.colors.border),
                              const SizedBox(height: 12),

                              SizedBox(
                                height: 50,
                                child: _ActionButton(
                                  state: state,
                                  onQuote: notifier.getQuote,
                                  onPreview: () async {
                                    final q = state.quote;
                                    if (q == null) return;
                                    final confirmed = await showAppDialog<bool>(
                                      context: context,
                                      builder: (_) => SwapConfirmDialog(
                                        quote: q,
                                        assetIn: assetFor(state.tokenIn),
                                        assetOut: assetFor(state.tokenOut),
                                        amountIn: state.amountIn,
                                        effectiveMaxFeeGwei: state.effectiveMaxFeeGwei,
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await notifier.executeSwap();
                                    }
                                  },
                                ),
                              ),

                              // Inline "Swap Again" removed — handled by
                              // SwapResultDialog (Close / Swap Again) at
                              // the AppShell layer.
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Adaptive action button — Get Quote → Swap
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.state,
    required this.onQuote,
    required this.onPreview,
  });

  final SwapState state;
  final VoidCallback onQuote;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final isQuoting = state.status == SwapStatus.quoting;
    final isSwapping = state.status == SwapStatus.swapping;
    final hasQuote = state.status == SwapStatus.quoted;
    final isLoading = isQuoting || isSwapping;

    final showPreview = hasQuote || isSwapping;
    final canAct = !isLoading && (showPreview || state.canQuote);

    // Distinct disabled label when balance is exceeded.
    final insufficientBalance = !showPreview && state.exceedsBalance && !isLoading;

    final bg = showPreview ? context.colors.primary : context.colors.primary;

    final label = insufficientBalance
        ? 'Insufficient Balance'
        : showPreview
        ? 'Preview Swap'
        : 'Get Quote';

    return FilledButton(
      onPressed: canAct ? (showPreview ? onPreview : onQuote) : null,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.textPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  insufficientBalance
                      ? Icons.account_balance_wallet_outlined
                      : showPreview
                      ? Icons.visibility_outlined
                      : Icons.search_rounded,
                  size: 16,
                  color: context.colors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact rate banner — header-only summary above the gas card
// ---------------------------------------------------------------------------

class _RateBanner extends StatelessWidget {
  const _RateBanner({
    required this.quote,
    required this.assetIn,
    required this.assetOut,
    required this.amountIn,
    required this.isRefreshing,
  });

  final SwapQuote quote;
  final SwapAsset? assetIn;
  final SwapAsset? assetOut;
  final String amountIn;
  final bool isRefreshing;

  String get _rateLabel {
    final inAmt = double.tryParse(amountIn);
    final outAmt = double.tryParse(quote.amountOut);
    if (inAmt == null || outAmt == null || inAmt == 0) return '—';
    final rate = outAmt / inAmt;
    final fmt = _fmtRate(rate);
    final inSym = assetIn?.symbol ?? '?';
    final outSym = assetOut?.symbol ?? '?';
    return '1 $inSym = $fmt $outSym';
  }

  static String _fmtRate(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          if (isRefreshing)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: context.colors.textSecondary,
              ),
            )
          else
            Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: context.colors.success,
            ),
          const SizedBox(width: 8),
          Text(
            _rateLabel,
            style: AppTextStyles.mono.copyWith(
              color: context.colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: context.colors.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
