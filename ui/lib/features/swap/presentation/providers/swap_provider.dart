import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:nox/core/gas/gas_override.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/swap/data/swap_grpc_repository.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/domain/swap_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swap_provider.g.dart';

// ---------------------------------------------------------------------------
// Swap asset model + provider (user's tokens available for swapping)
// ---------------------------------------------------------------------------

@immutable
class SwapAsset {
  const SwapAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    this.tokenAddress,
  });

  final String? tokenAddress; // null = ETH
  final String symbol;
  final String name;
  final String balance;

  bool get isEth => tokenAddress == null;

  String get address => isEth ? 'ETH' : tokenAddress!;

  @override
  bool operator ==(Object other) => other is SwapAsset && other.tokenAddress == tokenAddress;

  @override
  int get hashCode => tokenAddress.hashCode;
}

/// Well-known Ethereum mainnet tokens always shown in the swap selector.
/// Balances are overridden if the user has them in their wallet.
const _kWellKnown = [
  SwapAsset(symbol: 'ETH', name: 'Ethereum', tokenAddress: null, balance: '0'),
  SwapAsset(
    symbol: 'WETH',
    name: 'Wrapped Ether',
    tokenAddress: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    balance: '0',
  ),
  SwapAsset(
    symbol: 'USDC',
    name: 'USD Coin',
    tokenAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    balance: '0',
  ),
  SwapAsset(
    symbol: 'USDT',
    name: 'Tether USD',
    tokenAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    balance: '0',
  ),
  SwapAsset(
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    tokenAddress: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    balance: '0',
  ),
  SwapAsset(
    symbol: 'WBTC',
    name: 'Wrapped Bitcoin',
    tokenAddress: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
    balance: '0',
  ),
];

@riverpod
Future<List<SwapAsset>> swappableAssets(Ref ref) async {
  // Fetch user's token balances (watched tokens only).
  final userBalances = <String?, String>{};
  try {
    const repo = BalanceGrpcRepository();
    final res = await repo.getBalances();
    // ETH native balance
    userBalances[null] = res.ethBalance;
    for (final t in res.tokens) {
      userBalances[t.address.toLowerCase()] = t.balance;
    }
  } on Object catch (_) {
    // proceed with zero balances
  }

  String balanceFor(String? addr) => userBalances[addr?.toLowerCase()] ?? '0';

  // Merge: well-known tokens with real balances first.
  final result = _kWellKnown
      .map(
        (a) => SwapAsset(
          symbol: a.symbol,
          name: a.name,
          tokenAddress: a.tokenAddress,
          balance: balanceFor(a.tokenAddress),
        ),
      )
      .toList();

  // Append any user-watched tokens not in the well-known list.
  final knownAddrs = _kWellKnown
      .where((a) => a.tokenAddress != null)
      .map((a) => a.tokenAddress!.toLowerCase())
      .toSet();

  for (final entry in userBalances.entries) {
    final addr = entry.key;
    if (addr == null) continue; // ETH already included
    if (knownAddrs.contains(addr.toLowerCase())) continue;
    // Unknown ERC-20 the user is watching — include it.
    result.add(
      SwapAsset(
        symbol: addr.substring(0, 6).toUpperCase(),
        name: addr,
        tokenAddress: addr,
        balance: entry.value,
      ),
    );
  }

  return result;
}

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

@riverpod
SwapRepository swapRepository(Ref ref) => const SwapGrpcRepository();

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SwapStatus { idle, quoting, quoted, swapping, success, failure }

class SwapState {
  const SwapState({
    this.tokenIn = 'ETH',
    this.tokenOut = '',
    this.amountIn = '',
    this.balanceIn = '',
    this.poolFee = 3000,
    this.status = SwapStatus.idle,
    this.quote,
    this.txHash,
    this.errorMessage,
    this.gasTier = GasTier.normal,
    this.customPriorityGwei = '',
    this.customMaxGwei = '',
  });

  final String tokenIn;
  final String tokenOut;
  final String amountIn;

  /// Raw numeric balance of the selected input asset (e.g. "0.00865873").
  final String balanceIn;
  final int poolFee;
  final SwapStatus status;
  final SwapQuote? quote;
  final String? txHash;
  final String? errorMessage;

  /// Selected gas tier preset (Slow / Normal / Fast / Custom). Maps to a
  /// multiplier on the network priority fee — see [gasOverride].
  final GasTier gasTier;
  final String customPriorityGwei;
  final String customMaxGwei;

  /// True when entered amount exceeds the available balance.
  bool get exceedsBalance {
    if (balanceIn.isEmpty || amountIn.isEmpty) return false;
    final bal = double.tryParse(balanceIn) ?? 0;
    final amt = double.tryParse(amountIn) ?? 0;
    return amt > bal;
  }

  bool get canQuote =>
      tokenIn.isNotEmpty && tokenOut.isNotEmpty && amountIn.isNotEmpty && !exceedsBalance;

  bool get isLoading => status == SwapStatus.quoting || status == SwapStatus.swapping;

  SwapState copyWith({
    String? tokenIn,
    String? tokenOut,
    String? amountIn,
    String? balanceIn,
    int? poolFee,
    SwapStatus? status,
    SwapQuote? quote,
    String? txHash,
    String? errorMessage,
    GasTier? gasTier,
    String? customPriorityGwei,
    String? customMaxGwei,
    bool clearQuote = false,
    bool clearTx = false,
    bool clearError = false,
  }) {
    return SwapState(
      tokenIn: tokenIn ?? this.tokenIn,
      tokenOut: tokenOut ?? this.tokenOut,
      amountIn: amountIn ?? this.amountIn,
      balanceIn: balanceIn ?? this.balanceIn,
      poolFee: poolFee ?? this.poolFee,
      status: status ?? this.status,
      quote: clearQuote ? null : (quote ?? this.quote),
      txHash: clearTx ? null : (txHash ?? this.txHash),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      gasTier: gasTier ?? this.gasTier,
      customPriorityGwei: customPriorityGwei ?? this.customPriorityGwei,
      customMaxGwei: customMaxGwei ?? this.customMaxGwei,
    );
  }

  /// Resolves (priority, max) gwei for the current tier. Mirrors Send's
  /// tier-aware approach: cap shifts ×0.85 / ×1.00 / ×1.25 across
  /// Slow/Normal/Fast, priority follows the priorityMultiplier. Custom
  /// passes through user values verbatim. Returns `GasOverride.auto` only
  /// for Normal (network suggestion) or when we have no quote to scale.
  GasOverride get gasOverride {
    if (gasTier == GasTier.custom) {
      return GasOverride(
        priorityGwei: customPriorityGwei.isEmpty ? null : customPriorityGwei,
        maxGwei: customMaxGwei.isEmpty ? null : customMaxGwei,
      );
    }
    if (gasTier == GasTier.normal || quote == null) return GasOverride.auto;

    final maxFee = double.tryParse(quote?.maxFeeGwei ?? '') ?? 0;
    if (maxFee == 0) return GasOverride.auto;

    // SwapQuote doesn't surface priorityFee separately, so we don't try to
    // override priority — backend's network suggestion stays intact. Only
    // the cap shifts. That's enough to make the headline gwei meaningfully
    // tier-dependent on the UI side.
    return GasOverride(
      priorityGwei: null,
      maxGwei: (maxFee * gasTier.maxFeeMultiplier).toStringAsFixed(4),
    );
  }

  /// Tier-adjusted max-fee per gas (gwei). Used by the swap gas card to
  /// render the "0.51 Gwei · $0.14" reading that actually changes when the
  /// user picks a different tier (otherwise Slow/Normal/Fast on an
  /// uncongested network would all round to the same number).
  double get effectiveMaxFeeGwei {
    if (quote == null) return 0;
    if (gasTier == GasTier.custom) {
      final c = double.tryParse(customMaxGwei);
      if (c != null && c > 0) return c;
    }
    final baseMax = double.tryParse(quote!.maxFeeGwei ?? '') ?? 0;
    return baseMax * gasTier.maxFeeMultiplier;
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class SwapNotifier extends _$SwapNotifier {
  Timer? _debounce;
  Timer? _autoRefresh;

  SwapRepository get _repository => ref.read(swapRepositoryProvider);

  @override
  SwapState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _autoRefresh?.cancel();
    });
    return const SwapState();
  }

  // -- Field updates ---------------------------------------------------------

  void setTokenIn(String value) {
    _cancelRefresh();
    state = state.copyWith(
      tokenIn: value,
      status: SwapStatus.idle,
      clearQuote: true,
      clearError: true,
    );
    _scheduleQuote();
  }

  /// Update the available balance for the input token so `canQuote` can
  /// validate that the entered amount doesn't exceed what the user holds.
  void setBalanceIn(String rawBalance) {
    // Strip any non-numeric characters (e.g. symbol suffix like "0.008 ETH").
    final cleaned = rawBalance.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned == state.balanceIn) return;
    state = state.copyWith(balanceIn: cleaned);
  }

  void setTokenOut(String value) {
    _cancelRefresh();
    state = state.copyWith(
      tokenOut: value,
      status: SwapStatus.idle,
      clearQuote: true,
      clearError: true,
    );
    _scheduleQuote();
  }

  void setAmountIn(String value) {
    _cancelRefresh();
    state = state.copyWith(
      amountIn: value,
      status: SwapStatus.idle,
      clearQuote: true,
      clearError: true,
    );
    _scheduleQuote();
  }

  void setPoolFee(int fee) {
    _cancelRefresh();
    state = state.copyWith(
      poolFee: fee,
      status: SwapStatus.idle,
      clearQuote: true,
      clearError: true,
    );
    _scheduleQuote();
  }

  void swapDirection() {
    _cancelRefresh();
    final oldIn = state.tokenIn;
    final oldOut = state.tokenOut;
    state = state.copyWith(
      tokenIn: oldOut,
      tokenOut: oldIn,
      status: SwapStatus.idle,
      clearQuote: true,
      clearError: true,
    );
    _scheduleQuote();
  }

  // -- Quote -----------------------------------------------------------------

  /// Debounces the quote request by 500ms.
  void _scheduleQuote() {
    _debounce?.cancel();
    if (!state.canQuote) return;
    _debounce = Timer(const Duration(milliseconds: 500), getQuote);
  }

  Future<void> getQuote() async {
    if (!state.canQuote) return;
    _cancelRefresh();
    state = state.copyWith(status: SwapStatus.quoting, clearError: true);
    try {
      final quote = await _repository.quote(
        state.tokenIn,
        state.tokenOut,
        state.amountIn,
        state.poolFee,
      );
      state = state.copyWith(status: SwapStatus.quoted, quote: quote);
      _startAutoRefresh();
    } on Object catch (e) {
      state = state.copyWith(
        status: SwapStatus.failure,
        errorMessage: errorMessage(e),
        clearQuote: true,
      );
    }
  }

  // -- Execute swap ----------------------------------------------------------

  Future<void> executeSwap() async {
    final quote = state.quote;
    if (quote == null) return;
    _cancelRefresh();

    // Apply 0.5% slippage to compute amountOutMin.
    final amountOutMin = _applySlippage(quote.amountOut, slippagePct: 0.005);

    state = state.copyWith(
      status: SwapStatus.swapping,
      clearError: true,
      clearTx: true,
    );
    try {
      final result = await _repository.execute(
        state.tokenIn,
        state.tokenOut,
        state.amountIn,
        amountOutMin,
        state.poolFee,
        gas: state.gasOverride,
      );
      state = state.copyWith(
        status: result.success ? SwapStatus.success : SwapStatus.failure,
        txHash: result.txHash,
        errorMessage: result.success ? null : 'Transaction failed',
      );
    } on Object catch (e) {
      state = state.copyWith(
        status: SwapStatus.failure,
        errorMessage: errorMessage(e),
      );
    }
  }

  void setGasTier(GasTier tier) {
    state = state.copyWith(gasTier: tier);
  }

  void setCustomPriorityGwei(String s) {
    state = state.copyWith(customPriorityGwei: s.trim());
  }

  void setCustomMaxGwei(String s) {
    state = state.copyWith(customMaxGwei: s.trim());
  }

  // -- Reset -----------------------------------------------------------------

  void reset() {
    _cancelRefresh();
    _debounce?.cancel();
    state = const SwapState();
  }

  // -- Auto-refresh ----------------------------------------------------------

  void _startAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh = Timer.periodic(const Duration(seconds: 15), (_) {
      if (state.status == SwapStatus.quoted) {
        unawaited(getQuote());
      } else {
        _cancelRefresh();
      }
    });
  }

  void _cancelRefresh() => _autoRefresh?.cancel();

  // -- Helpers ---------------------------------------------------------------

  /// Reduces [amount] by [slippagePct] (e.g. 0.005 for 0.5%).
  String _applySlippage(String amount, {required double slippagePct}) {
    final value = double.tryParse(amount);
    if (value == null) return amount;
    final min = value * (1 - slippagePct);
    return min.toStringAsFixed(18).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
