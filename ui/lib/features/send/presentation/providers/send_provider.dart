import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/send/data/send_grpc_repository.dart';
import 'package:nox/features/send/domain/send_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Domain models are imported directly; re-export them so widgets only need one import.
export '../../domain/send_repository.dart';

part 'send_provider.g.dart';

// ── Repository & use-case ────────────────────────────────────────────────────

@riverpod
SendRepository sendRepository(Ref ref) => const SendGrpcRepository();

@riverpod
SendUseCase sendUseCase(Ref ref) => SendUseCase(ref.watch(sendRepositoryProvider));

// ── Asset model ──────────────────────────────────────────────────────────────

@immutable
class SendAsset {
  const SendAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    this.tokenAddress,
  });

  /// null means ETH (native asset).
  final String? tokenAddress;
  final String symbol;
  final String name;
  final String balance;

  bool get isEth => tokenAddress == null;

  @override
  bool operator ==(Object other) => other is SendAsset && other.tokenAddress == tokenAddress;

  @override
  int get hashCode => tokenAddress.hashCode;
}

// ── Balances provider ─────────────────────────────────────────────────────────

/// Repository for ETH + token balance lookups.
@riverpod
BalanceRepository balanceRepository(Ref ref) => const BalanceGrpcRepository();

/// Loads ETH + token balances for the asset selector.
@riverpod
Future<List<SendAsset>> sendableAssets(Ref ref) async {
  try {
    final balances = await ref.watch(balanceRepositoryProvider).getBalances();
    return [
      SendAsset(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: balances.ethBalance,
      ),
      ...balances.tokens.map(
        (t) => SendAsset(
          symbol: t.symbol,
          name: t.name,
          tokenAddress: t.address,
          balance: t.balance,
        ),
      ),
    ];
  } on Object catch (_) {
    return const [SendAsset(symbol: 'ETH', name: 'Ethereum', balance: '0')];
  }
}

// ── Send flow state ──────────────────────────────────────────────────────────

enum SendStatus { idle, estimating, ready, sending, success, failure }

class SendState {
  const SendState({
    this.toAddress = '',
    this.amount = '',
    this.selectedAsset,
    this.availableAssets = const [],
    this.status = SendStatus.idle,
    this.gasEstimate,
    this.gasTier = GasTier.normal,
    this.customPriorityGwei = '',
    this.customMaxGwei = '',
    this.txResult,
    this.errorMessage,
    this.toAddressError,
    this.amountError,
  });

  final String toAddress;
  final String amount;
  final SendAsset? selectedAsset;
  final List<SendAsset> availableAssets;
  final SendStatus status;
  final GasEstimate? gasEstimate;

  /// Selected gas tier preset. Maps to a multiplier on the network-suggested
  /// priority fee — see GasTier.priorityMultiplier.
  final GasTier gasTier;

  /// Custom-tier inputs. Empty strings mean "fall back to network suggestion"
  /// for that field. Only consulted when [gasTier] == GasTier.custom.
  final String customPriorityGwei;
  final String customMaxGwei;

  final TxResult? txResult;
  final String? errorMessage;
  final String? toAddressError;
  final String? amountError;

  bool get isFormValid =>
      toAddressError == null && amountError == null && toAddress.isNotEmpty && amount.isNotEmpty;

  bool get isBusy => status == SendStatus.estimating || status == SendStatus.sending;

  SendState copyWith({
    String? toAddress,
    String? amount,
    SendAsset? selectedAsset,
    List<SendAsset>? availableAssets,
    SendStatus? status,
    GasEstimate? gasEstimate,
    GasTier? gasTier,
    String? customPriorityGwei,
    String? customMaxGwei,
    TxResult? txResult,
    String? errorMessage,
    String? toAddressError,
    String? amountError,
    bool clearGasEstimate = false,
    bool clearTxResult = false,
    bool clearError = false,
    bool clearToAddressError = false,
    bool clearAmountError = false,
  }) {
    return SendState(
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      availableAssets: availableAssets ?? this.availableAssets,
      status: status ?? this.status,
      gasEstimate: clearGasEstimate ? null : (gasEstimate ?? this.gasEstimate),
      gasTier: gasTier ?? this.gasTier,
      customPriorityGwei: customPriorityGwei ?? this.customPriorityGwei,
      customMaxGwei: customMaxGwei ?? this.customMaxGwei,
      txResult: clearTxResult ? null : (txResult ?? this.txResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toAddressError: clearToAddressError ? null : (toAddressError ?? this.toAddressError),
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
    );
  }

  /// Resolves the (priority, max) gwei strings the repository should send
  /// based on the current tier. Empty strings → repository falls back to
  /// network suggestions on that side.
  GasOverride get gasOverride {
    final est = gasEstimate;
    if (gasTier == GasTier.custom) {
      return GasOverride(
        priorityGwei: customPriorityGwei.isEmpty ? null : customPriorityGwei,
        maxGwei: customMaxGwei.isEmpty ? null : customMaxGwei,
      );
    }
    if (est == null || gasTier == GasTier.normal) return GasOverride.auto;

    final basePriority = double.tryParse(est.priorityFee) ?? 0;
    final baseMax = double.tryParse(est.maxFee) ?? 0;
    if (basePriority == 0 || baseMax == 0) return GasOverride.auto;

    // Both priority and cap shift with the tier. Cap-shift is what makes
    // Slow / Normal / Fast visibly different in the headline reading even
    // on an uncongested network (where priority alone is sub-percent).
    final priority = (basePriority * gasTier.priorityMultiplier).toStringAsFixed(4);
    final maxFee = (baseMax * gasTier.maxFeeMultiplier).toStringAsFixed(4);
    return GasOverride(priorityGwei: priority, maxGwei: maxFee);
  }

  /// Effective max-fee per gas (gwei) — the cap on what the user will pay
  /// at worst. This is what the headline "0.41 Gwei" reading shows: the
  /// upper bound, which actually moves between tiers (×0.85 / ×1.00 / ×1.25
  /// for Slow / Normal / Fast).
  double get effectiveMaxFeeGwei {
    final est = gasEstimate;
    if (est == null) return 0;
    if (gasTier == GasTier.custom) {
      return double.tryParse(customMaxGwei) ?? double.tryParse(est.maxFee) ?? 0;
    }
    final baseMax = double.tryParse(est.maxFee) ?? 0;
    return baseMax * gasTier.maxFeeMultiplier;
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

@riverpod
class SendNotifier extends _$SendNotifier {
  @override
  SendState build() {
    ref.onDispose(() => _estimateDebounce?.cancel());
    return const SendState();
  }

  void setAvailableAssets(List<SendAsset> assets) {
    // Preserve an already-set selection (e.g. deep-link from Tokens screen
    // sets USDC via setSelectedAsset before SendForm's postFrame fires
    // this default-to-first reset). Only fall through to assets.first
    // when nothing is selected yet.
    final selected = state.selectedAsset ?? (assets.isNotEmpty ? assets.first : null);
    state = state.copyWith(availableAssets: assets, selectedAsset: selected);
  }

  Timer? _estimateDebounce;

  void _scheduleEstimate() {
    _estimateDebounce?.cancel();
    if (!state.isFormValid) return;
    _estimateDebounce = Timer(const Duration(milliseconds: 800), estimateGas);
  }

  void setToAddress(String value) {
    final error = _validateAddress(value);
    state = state.copyWith(
      toAddress: value,
      toAddressError: error,
      clearToAddressError: error == null,
      clearGasEstimate: true,
      status: SendStatus.idle,
    );
    _scheduleEstimate();
  }

  void setAmount(String value) {
    final error = _validateAmount(value, state.selectedAsset?.balance);
    state = state.copyWith(
      amount: value,
      amountError: error,
      clearAmountError: error == null,
      clearGasEstimate: true,
      status: SendStatus.idle,
    );
    _scheduleEstimate();
  }

  void setSelectedAsset(SendAsset asset) {
    state = state.copyWith(
      selectedAsset: asset,
      clearGasEstimate: true,
      clearAmountError: true,
      amount: '',
      status: SendStatus.idle,
    );
    _scheduleEstimate();
  }

  void setMaxAmount() {
    final asset = state.selectedAsset;
    if (asset == null) return;
    final balance = double.tryParse(asset.balance) ?? 0;
    if (balance <= 0) return;

    final amountStr = asset.isEth
        ? _maxEthMinusGas(balance)
        : asset.balance; // Tokens: gas paid in ETH separately, full balance OK.

    state = state.copyWith(
      amount: amountStr,
      clearAmountError: true,
      clearGasEstimate: true,
      status: SendStatus.idle,
    );
    _scheduleEstimate();
  }

  /// Computes "max ETH the user can send" by reserving room for gas.
  /// Uses the latest gas estimate if available with a 20% safety margin
  /// to absorb price drift; falls back to a generous 0.0005 ETH buffer
  /// when no estimate has been fetched yet (covers any realistic
  /// 21k-gas transfer at <24 gwei).
  String _maxEthMinusGas(double balance) {
    final est = state.gasEstimate;
    double reserve;
    if (est != null) {
      final cap = state.effectiveMaxFeeGwei;
      reserve = est.estimatedGas * cap * 1e-9 * 1.2;
    } else {
      reserve = 0.0005;
    }
    final maxAmount = (balance - reserve).clamp(0.0, double.infinity);
    if (maxAmount == 0) return '0';
    return maxAmount
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> estimateGas() async {
    if (!state.isFormValid) return;
    state = state.copyWith(status: SendStatus.estimating, clearError: true);
    try {
      final estimate = await ref.read(sendUseCaseProvider).getGasEstimate();
      state = state.copyWith(status: SendStatus.ready, gasEstimate: estimate);
    } on Object catch (e) {
      state = state.copyWith(
        status: SendStatus.idle,
        errorMessage: 'Gas estimate failed: ${errorMessage(e)}',
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

  Future<bool> send() async {
    if (!state.isFormValid || state.isBusy) return false;
    state = state.copyWith(status: SendStatus.sending, clearError: true);
    try {
      final useCase = ref.read(sendUseCaseProvider);
      final asset = state.selectedAsset;
      final gas = state.gasOverride;
      final TxResult result;
      if (asset == null || asset.isEth) {
        result = await useCase.sendEth(
          state.toAddress,
          state.amount,
          gas: gas,
        );
      } else {
        result = await useCase.sendToken(
          state.toAddress,
          asset.tokenAddress!,
          state.amount,
          gas: gas,
        );
      }
      state = state.copyWith(
        status: result.success ? SendStatus.success : SendStatus.failure,
        txResult: result,
      );
      return result.success;
    } on Object catch (e) {
      state = state.copyWith(
        status: SendStatus.failure,
        errorMessage: errorMessage(e),
      );
      return false;
    }
  }

  void reset() => state = const SendState();

  // ── Validation ────────────────────────────────────────────────────────────

  static final _ethAddressRe = RegExp(r'^0x[0-9a-fA-F]{40}$');

  static String? _validateAddress(String value) {
    if (value.isEmpty) return null;
    return _ethAddressRe.hasMatch(value) ? null : 'Invalid address (must be 0x + 40 hex chars)';
  }

  static String? _validateAmount(String value, String? balance) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    final bal = double.tryParse(balance ?? '0') ?? 0;
    if (parsed > bal) return 'Insufficient balance';
    return null;
  }
}
