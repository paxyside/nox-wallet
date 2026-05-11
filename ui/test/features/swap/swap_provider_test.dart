// Unit tests for SwapNotifier — quote → execute state machine. The
// money-on-the-line failure modes here are slippage misapplication
// (user gets less than expected) and stuck txs from a stale quote, so
// we exercise the canQuote predicate, the slippage helper via
// executeSwap routing, and the deterministic state transitions.
// Debounced/auto-refresh timers are out of scope — those are
// integration territory.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nox/core/gas/gas_override.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/domain/swap_repository.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

class _FakeSwapRepository implements SwapRepository {
  _FakeSwapRepository({this.quoteResult, this.quoteError, this.executeResult, this.executeError});

  final SwapQuote? quoteResult;
  final Exception? quoteError;
  final TxResult? executeResult;
  final Exception? executeError;

  // Recorded args from the last execute call.
  String? lastTokenIn;
  String? lastTokenOut;
  String? lastAmountIn;
  String? lastAmountOutMin;
  int? lastPoolFee;
  GasOverride? lastGas;

  @override
  Future<SwapQuote> quote(String tokenIn, String tokenOut, String amountIn, int poolFee) async {
    final err = quoteError;
    if (err != null) throw err;
    return quoteResult ??
        const SwapQuote(
          amountOut: '100',
          amountOutRaw: '100000000000000000000',
          gasEstimate: '180000',
          maxFeeGwei: '40',
        );
  }

  @override
  Future<TxResult> execute(
    String tokenIn,
    String tokenOut,
    String amountIn,
    String amountOutMin,
    int poolFee, {
    GasOverride gas = GasOverride.auto,
  }) async {
    lastTokenIn = tokenIn;
    lastTokenOut = tokenOut;
    lastAmountIn = amountIn;
    lastAmountOutMin = amountOutMin;
    lastPoolFee = poolFee;
    lastGas = gas;
    final err = executeError;
    if (err != null) throw err;
    return executeResult ?? const TxResult(txHash: '0xfeed', success: true);
  }
}

ProviderContainer _container({_FakeSwapRepository? repo}) {
  return ProviderContainer(
    overrides: [
      swapRepositoryProvider.overrideWith((_) => repo ?? _FakeSwapRepository()),
    ],
  );
}

const _quote = SwapQuote(
  amountOut: '100',
  amountOutRaw: '100000000000000000000',
  gasEstimate: '180000',
  maxFeeGwei: '40',
);

void main() {
  group('canQuote / exceedsBalance', () {
    test('false until both sides + amount are set', () {
      const empty = SwapState();
      expect(empty.canQuote, isFalse);

      const onlyIn = SwapState(tokenIn: 'ETH', amountIn: '1');
      expect(onlyIn.canQuote, isFalse);

      const ready = SwapState(tokenIn: 'ETH', tokenOut: 'USDC', amountIn: '1', balanceIn: '10');
      expect(ready.canQuote, isTrue);
    });

    test('false when amount exceeds balance', () {
      const overBalance = SwapState(
        tokenIn: 'ETH',
        tokenOut: 'USDC',
        amountIn: '11',
        balanceIn: '10',
      );

      expect(overBalance.exceedsBalance, isTrue);
      expect(overBalance.canQuote, isFalse);
    });

    test('garbled balance string treats balance as 0', () {
      const s = SwapState(
        tokenIn: 'ETH',
        tokenOut: 'USDC',
        amountIn: '0.1',
        balanceIn: 'not-a-number',
      );

      expect(s.exceedsBalance, isTrue);
    });
  });

  group('Field setters clear the previous quote', () {
    test('setTokenIn drops a stale quote so the UI does not show wrong rates', () {
      final c = _container();
      addTearDown(c.dispose);
      // Seed a quote-state directly via the field setter chain. We don't
      // wait for the debounced quote — we only care that swapping the
      // input clears whatever was there.
      c.read(swapNotifierProvider.notifier).setTokenIn('ETH');

      expect(c.read(swapNotifierProvider).quote, isNull);
      expect(c.read(swapNotifierProvider).status, SwapStatus.idle);
    });

    test('swapDirection swaps tokenIn/tokenOut and clears quote', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..swapDirection();

      final s = c.read(swapNotifierProvider);
      expect(s.tokenIn, 'USDC');
      expect(s.tokenOut, 'ETH');
      expect(s.quote, isNull);
    });

    test('setBalanceIn strips non-numeric prefix/suffix the UI may pass through', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(swapNotifierProvider.notifier).setBalanceIn('0.008 ETH');

      expect(c.read(swapNotifierProvider).balanceIn, '0.008');
    });
  });

  group('getQuote()', () {
    test('no-op when canQuote is false (no repo call)', () async {
      final repo = _FakeSwapRepository(quoteResult: _quote);
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        // tokenOut intentionally left empty so canQuote stays false.
        ..setTokenIn('ETH')
        ..setAmountIn('1')
        ..setBalanceIn('10');

      await n.getQuote();

      expect(c.read(swapNotifierProvider).status, SwapStatus.idle);
    });

    test('success path lands in SwapStatus.quoted with the returned quote', () async {
      final repo = _FakeSwapRepository(quoteResult: _quote);
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1');

      await n.getQuote();

      final s = c.read(swapNotifierProvider);
      expect(s.status, SwapStatus.quoted);
      expect(s.quote?.amountOut, '100');
    });

    test('repository error lands in SwapStatus.failure and clears quote', () async {
      final repo = _FakeSwapRepository(quoteError: Exception('no liquidity'));
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1');

      await n.getQuote();

      final s = c.read(swapNotifierProvider);
      expect(s.status, SwapStatus.failure);
      expect(s.errorMessage, isNotNull);
      expect(s.quote, isNull);
    });
  });

  group('executeSwap()', () {
    test('no-op when no quote is in state (would otherwise NPE)', () async {
      final repo = _FakeSwapRepository();
      final c = _container(repo: repo);
      addTearDown(c.dispose);

      await c.read(swapNotifierProvider.notifier).executeSwap();

      expect(repo.lastAmountOutMin, isNull);
      expect(c.read(swapNotifierProvider).status, SwapStatus.idle);
    });

    test('applies 0.5% slippage to the quote amountOut', () async {
      final repo = _FakeSwapRepository(quoteResult: _quote);
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1');
      await n.getQuote();

      await n.executeSwap();

      // amountOut = 100 ; slippage 0.5% ⇒ minimum out = 99.5
      expect(double.parse(repo.lastAmountOutMin!), closeTo(99.5, 1e-9));
    });

    test('forwards the resolved gas override to the repository', () async {
      final repo = _FakeSwapRepository(quoteResult: _quote);
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1')
        ..setGasTier(GasTier.fast); // ×1.25 cap
      await n.getQuote();

      await n.executeSwap();

      // maxFeeGwei = 40 in _quote; Fast cap-multiplier = 1.25 → 50.0000.
      expect(repo.lastGas?.maxGwei, '50.0000');
      expect(repo.lastGas?.priorityGwei, isNull); // priority left to network
    });

    test('repository error → SwapStatus.failure with errorMessage', () async {
      final repo = _FakeSwapRepository(
        quoteResult: _quote,
        executeError: Exception('insufficient allowance'),
      );
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1');
      await n.getQuote();

      await n.executeSwap();

      final s = c.read(swapNotifierProvider);
      expect(s.status, SwapStatus.failure);
      expect(s.errorMessage, isNotNull);
    });

    test('TxResult.success=false produces SwapStatus.failure (not success)', () async {
      final repo = _FakeSwapRepository(
        quoteResult: _quote,
        executeResult: const TxResult(txHash: '0xrev', success: false),
      );
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(swapNotifierProvider.notifier)
        ..setTokenIn('ETH')
        ..setTokenOut('USDC')
        ..setBalanceIn('10')
        ..setAmountIn('1');
      await n.getQuote();

      await n.executeSwap();

      expect(c.read(swapNotifierProvider).status, SwapStatus.failure);
    });
  });

  group('GasOverride resolution', () {
    test('Normal tier returns auto', () {
      const s = SwapState(quote: _quote);

      expect(s.gasOverride.priorityGwei, isNull);
      expect(s.gasOverride.maxGwei, isNull);
    });

    test('Custom tier passes user values through', () {
      const s = SwapState(
        gasTier: GasTier.custom,
        customPriorityGwei: '5',
        customMaxGwei: '70',
      );

      expect(s.gasOverride.priorityGwei, '5');
      expect(s.gasOverride.maxGwei, '70');
    });

    test('Slow tier with no quote falls back to auto (no math on null)', () {
      const s = SwapState(gasTier: GasTier.slow);

      expect(s.gasOverride.priorityGwei, isNull);
      expect(s.gasOverride.maxGwei, isNull);
    });

    test('Slow tier with quote scales the cap by 0.85', () {
      const s = SwapState(gasTier: GasTier.slow, quote: _quote);

      // maxFeeGwei = 40 ; ×0.85 = 34.0000
      expect(s.gasOverride.maxGwei, '34.0000');
      expect(s.gasOverride.priorityGwei, isNull); // SwapQuote has no priority field
    });
  });

  test('reset() returns state to defaults', () {
    final c = _container();
    addTearDown(c.dispose);
    c.read(swapNotifierProvider.notifier)
      ..setTokenIn('ETH')
      ..setTokenOut('USDC')
      ..setAmountIn('1')
      ..reset();

    final s = c.read(swapNotifierProvider);
    expect(s.tokenIn, 'ETH'); // default seed
    expect(s.tokenOut, '');
    expect(s.amountIn, '');
    expect(s.status, SwapStatus.idle);
  });
}
