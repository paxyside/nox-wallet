import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/widgets/swap_flip_button.dart';
import 'package:nox/features/swap/presentation/widgets/swap_form_meta_row.dart';
import 'package:nox/features/swap/presentation/widgets/swap_pay_card.dart';
import 'package:nox/features/swap/presentation/widgets/swap_receive_card.dart';

class SwapForm extends ConsumerStatefulWidget {
  const SwapForm({super.key});

  @override
  ConsumerState<SwapForm> createState() => _SwapFormState();
}

class _SwapFormState extends ConsumerState<SwapForm> {
  final TextEditingController _amountCtrl = TextEditingController();
  SwapAsset? _assetIn;
  SwapAsset? _assetOut;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(swapNotifierProvider).amountIn;
    if (existing.isNotEmpty) _amountCtrl.text = existing;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _initAssets(List<SwapAsset> assets) {
    if (_initialized || assets.isEmpty) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SwapAsset? findBySymbol(String sym) {
        try {
          return assets.firstWhere((a) => a.symbol == sym);
        } on Object catch (_) {
          return null;
        }
      }

      SwapAsset? findByAddress(String addr) {
        if (addr.isEmpty) return null;
        try {
          return assets.firstWhere(
            (a) => a.address.toLowerCase() == addr.toLowerCase(),
          );
        } on Object catch (_) {
          return null;
        }
      }

      // Honour any tokenIn / tokenOut that was already set on the
      // notifier (e.g. by SwapScreen's deep-link initState). Only fall
      // back to ETH/USDC defaults when nothing's been chosen yet.
      final st = ref.read(swapNotifierProvider);
      final preIn = findByAddress(st.tokenIn);
      final preOut = findByAddress(st.tokenOut);

      setState(() {
        _assetIn = preIn ?? findBySymbol('ETH') ?? assets.first;
        _assetOut =
            preOut ??
            findBySymbol('USDC') ??
            assets.firstWhere((a) => a != _assetIn, orElse: () => assets.first);
      });
      _push();
    });
  }

  void _push() {
    final n = ref.read(swapNotifierProvider.notifier);
    if (_assetIn != null) {
      n
        ..setTokenIn(_assetIn!.address)
        ..setBalanceIn(_assetIn!.balance);
    }
    if (_assetOut != null) n.setTokenOut(_assetOut!.address);
  }

  void _setFraction(double pct) {
    if (_assetIn == null) return;
    final raw = double.tryParse(_assetIn!.balance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final val = raw * pct;
    final s = val < 0.0001 ? val.toStringAsFixed(8) : val.toStringAsFixed(6);
    _amountCtrl.text = s;
    ref.read(swapNotifierProvider.notifier).setAmountIn(s);
  }

  void _flip() {
    setState(() {
      final tmp = _assetIn;
      _assetIn = _assetOut;
      _assetOut = tmp;
    });
    _push();
    _amountCtrl.clear();
    ref.read(swapNotifierProvider.notifier).setAmountIn('');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(swapNotifierProvider.select((s) => s.isLoading));
    final quoteOut = ref.watch(
      swapNotifierProvider.select((s) => s.quote?.amountOut ?? ''),
    );
    final assetsAsync = ref.watch(swappableAssetsProvider);

    return assetsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(
        'Failed to load tokens',
        style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
      ),
      data: (assets) {
        _initAssets(assets);
        final exceedsBalance = ref.watch(
          swapNotifierProvider.select((s) => s.exceedsBalance),
        );
        final hasQuote = ref.watch(
          swapNotifierProvider.select((s) => s.quote != null),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── You pay ──────────────────────────────────────────────────
            SwapPayCard(
              assets: assets.where((a) => a != _assetOut).toList(),
              selected: _assetIn,
              controller: _amountCtrl,
              locked: isLoading,
              exceedsBalance: exceedsBalance,
              onAssetChanged: (a) {
                setState(() => _assetIn = a);
                ref.read(swapNotifierProvider.notifier).setTokenIn(a.address);
                ref.read(swapNotifierProvider.notifier).setBalanceIn(a.balance);
              },
              onAmountChanged: ref.read(swapNotifierProvider.notifier).setAmountIn,
              onFraction: isLoading ? null : _setFraction,
              onMaxPressed: isLoading ? null : () => _setFraction(1),
            ),

            // ── Flip button ───────────────────────────────────────────────
            const SizedBox(height: 4),
            Center(child: SwapFlipButton(onTap: isLoading ? null : _flip)),
            const SizedBox(height: 4),

            // ── You receive ───────────────────────────────────────────────
            SwapReceiveCard(
              assets: assets.where((a) => a != _assetIn).toList(),
              selected: _assetOut,
              locked: isLoading,
              value: isLoading ? '…' : (quoteOut.isEmpty ? null : quoteOut),
              onAssetChanged: (a) {
                setState(() => _assetOut = a);
                ref.read(swapNotifierProvider.notifier).setTokenOut(a.address);
              },
            ),

            // ── Quote-preview meta strip ─────────────────────────────────
            // Surfaces slippage / route / network info in the otherwise-empty
            // space between cards and the Get Quote button. Once a real quote
            // arrives the dedicated CollapsibleQuote takes over, so we hide
            // this strip to avoid duplication.
            if (!hasQuote && !isLoading) ...[
              const SizedBox(height: 12),
              SwapFormMetaRow(assetIn: _assetIn, assetOut: _assetOut),
            ],
          ],
        );
      },
    );
  }
}
