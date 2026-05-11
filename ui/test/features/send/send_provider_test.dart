// Unit tests for SendNotifier — the state machine that drives the send
// flow (validate → estimate → ready → send → success/failure). Bugs
// here can lock funds: a wrong amount that passes validation, an
// address that types-as-invalid when it's actually fine, or a
// `setMaxAmount` that forgets to reserve gas. We exercise the
// validation predicates and the deterministic state transitions; the
// debounce-driven `estimateGas` call is left to integration coverage.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nox/core/widgets/gas_tier_picker.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';

class _FakeSendRepository implements SendRepository {
  _FakeSendRepository({this.sendEthResult, this.sendEthError});

  final TxResult? sendEthResult;
  final Exception? sendEthError;

  // Recorded args from the last send* call.
  String? lastSendToAddress;
  String? lastSendAmount;
  String? lastSendTokenAddress;
  GasOverride? lastGas;

  @override
  Future<GasEstimate> getGasEstimate() async => const GasEstimate(
        baseFee: '20',
        priorityFee: '2',
        maxFee: '40',
        estimatedGas: 21000,
      );

  @override
  Future<TxResult> sendEth(
    String toAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  }) async {
    lastSendToAddress = toAddress;
    lastSendAmount = amount;
    lastGas = gas;
    final err = sendEthError;
    if (err != null) throw err;
    return sendEthResult ?? const TxResult(txHash: '0xabc', success: true);
  }

  @override
  Future<TxResult> sendToken(
    String toAddress,
    String tokenAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  }) async {
    lastSendToAddress = toAddress;
    lastSendTokenAddress = tokenAddress;
    lastSendAmount = amount;
    lastGas = gas;
    return const TxResult(txHash: '0xdef', success: true);
  }
}

const _validAddress = '0x1111111111111111111111111111111111111111';
const _ethAsset = SendAsset(symbol: 'ETH', name: 'Ethereum', balance: '10');
const _usdcAsset = SendAsset(
  symbol: 'USDC',
  name: 'USD Coin',
  balance: '500',
  tokenAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
);

ProviderContainer _container({_FakeSendRepository? repo}) {
  return ProviderContainer(
    overrides: [
      sendRepositoryProvider.overrideWith((_) => repo ?? _FakeSendRepository()),
    ],
  );
}

void main() {
  group('Address validation', () {
    test('empty address is not flagged (form is incomplete, not invalid)', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier).setToAddress('');

      expect(c.read(sendNotifierProvider).toAddressError, isNull);
    });

    test('valid checksummed address passes', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier).setToAddress(_validAddress);

      expect(c.read(sendNotifierProvider).toAddressError, isNull);
    });

    test('non-hex characters are rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier).setToAddress(
            '0xZZZZ111111111111111111111111111111111111',
          );

      expect(c.read(sendNotifierProvider).toAddressError, isNotNull);
    });

    test('truncated address (39 hex chars) is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier).setToAddress(
            '0x111111111111111111111111111111111111111',
          );

      expect(c.read(sendNotifierProvider).toAddressError, isNotNull);
    });

    test('overlong address (41 hex chars) is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier).setToAddress('${_validAddress}1');

      expect(c.read(sendNotifierProvider).toAddressError, isNotNull);
    });
  });

  group('Amount validation', () {
    test('empty amount is not flagged', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('');

      expect(c.read(sendNotifierProvider).amountError, isNull);
    });

    test('non-numeric amount is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('abc');

      expect(c.read(sendNotifierProvider).amountError, isNotNull);
    });

    test('zero amount is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('0');

      expect(c.read(sendNotifierProvider).amountError, contains('greater than 0'));
    });

    test('negative amount is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('-1');

      expect(c.read(sendNotifierProvider).amountError, isNotNull);
    });

    test('amount above balance is rejected', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset) // balance = 10
        ..setAmount('11');

      expect(c.read(sendNotifierProvider).amountError, contains('Insufficient'));
    });

    test('amount equal to balance is accepted', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('10');

      expect(c.read(sendNotifierProvider).amountError, isNull);
    });
  });

  group('isFormValid', () {
    test('false when address empty', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('1');

      expect(c.read(sendNotifierProvider).isFormValid, isFalse);
    });

    test('false when amount empty', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setToAddress(_validAddress);

      expect(c.read(sendNotifierProvider).isFormValid, isFalse);
    });

    test('true when both valid', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setToAddress(_validAddress)
        ..setAmount('1');

      expect(c.read(sendNotifierProvider).isFormValid, isTrue);
    });
  });

  group('setMaxAmount', () {
    test('ETH path reserves a gas buffer (lower than full balance)', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset) // balance = 10
        ..setMaxAmount();

      final amount = c.read(sendNotifierProvider).amount;
      expect(double.parse(amount), lessThan(10.0));
      // Must still be very close — reserve is small (default fallback 0.0005).
      expect(double.parse(amount), greaterThan(9.99));
    });

    test('ERC-20 path uses full balance (gas paid in ETH separately)', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_usdcAsset) // balance = 500
        ..setMaxAmount();

      expect(c.read(sendNotifierProvider).amount, '500');
    });

    test('zero balance is a no-op', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(
          const SendAsset(symbol: 'ETH', name: 'Ethereum', balance: '0'),
        )
        ..setMaxAmount();

      // Amount stays empty — caller can decide what to render.
      expect(c.read(sendNotifierProvider).amount, '');
    });
  });

  group('Asset switching', () {
    test('clears amount + amountError + gas estimate so the user re-enters', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setAmount('5')
        ..setSelectedAsset(_usdcAsset);

      final s = c.read(sendNotifierProvider);
      expect(s.amount, '');
      expect(s.amountError, isNull);
      expect(s.selectedAsset?.symbol, 'USDC');
    });
  });

  group('send()', () {
    test('refuses to fire when form invalid', () async {
      final repo = _FakeSendRepository();
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        // Address missing.
        ..setAmount('1');

      final ok = await n.send();

      expect(ok, isFalse);
      expect(repo.lastSendToAddress, isNull);
    });

    test('routes ETH transfers to sendEth', () async {
      final repo = _FakeSendRepository();
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setToAddress(_validAddress)
        ..setAmount('0.5');

      final ok = await n.send();

      expect(ok, isTrue);
      expect(repo.lastSendToAddress, _validAddress);
      expect(repo.lastSendAmount, '0.5');
      expect(repo.lastSendTokenAddress, isNull);
      expect(c.read(sendNotifierProvider).status, SendStatus.success);
    });

    test('routes ERC-20 transfers to sendToken with the contract address', () async {
      final repo = _FakeSendRepository();
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_usdcAsset)
        ..setToAddress(_validAddress)
        ..setAmount('100');

      await n.send();

      expect(repo.lastSendTokenAddress, _usdcAsset.tokenAddress);
      expect(repo.lastSendAmount, '100');
    });

    test('failure path lands in SendStatus.failure with errorMessage', () async {
      final repo = _FakeSendRepository(sendEthError: Exception('rpc unavailable'));
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setToAddress(_validAddress)
        ..setAmount('1');

      final ok = await n.send();

      expect(ok, isFalse);
      final s = c.read(sendNotifierProvider);
      expect(s.status, SendStatus.failure);
      expect(s.errorMessage, isNotNull);
    });

    test('repository TxResult.success=false produces SendStatus.failure', () async {
      final repo = _FakeSendRepository(
        sendEthResult: const TxResult(txHash: '0xrev', success: false),
      );
      final c = _container(repo: repo);
      addTearDown(c.dispose);
      final n = c.read(sendNotifierProvider.notifier)
        ..setSelectedAsset(_ethAsset)
        ..setToAddress(_validAddress)
        ..setAmount('1');

      final ok = await n.send();

      expect(ok, isFalse);
      expect(c.read(sendNotifierProvider).status, SendStatus.failure);
    });
  });

  group('GasOverride / tier resolution', () {
    test('Normal tier with no estimate => GasOverride.auto', () {
      const s = SendState();

      expect(s.gasOverride.priorityGwei, isNull);
      expect(s.gasOverride.maxGwei, isNull);
    });

    test('Custom tier with empty fields falls back to network suggestion', () {
      const s = SendState(gasTier: GasTier.custom);

      expect(s.gasOverride.priorityGwei, isNull);
      expect(s.gasOverride.maxGwei, isNull);
    });

    test('Custom tier with values passes them through verbatim', () {
      const s = SendState(
        gasTier: GasTier.custom,
        customPriorityGwei: '3',
        customMaxGwei: '50',
      );

      expect(s.gasOverride.priorityGwei, '3');
      expect(s.gasOverride.maxGwei, '50');
    });

    test('Fast tier scales priority and cap by tier multipliers', () {
      const s = SendState(
        gasTier: GasTier.fast,
        gasEstimate: GasEstimate(
          baseFee: '20',
          priorityFee: '2',
          maxFee: '40',
          estimatedGas: 21000,
        ),
      );

      // priorityMultiplier=1.5 → 3.0000 ; maxFeeMultiplier=1.25 → 50.0000
      expect(s.gasOverride.priorityGwei, '3.0000');
      expect(s.gasOverride.maxGwei, '50.0000');
    });

    test('Slow tier with zero baseMax falls back to auto (no division-by-zero traps)', () {
      const s = SendState(
        gasTier: GasTier.slow,
        gasEstimate: GasEstimate(
          baseFee: '0',
          priorityFee: '0',
          maxFee: '0',
          estimatedGas: 21000,
        ),
      );

      expect(s.gasOverride.priorityGwei, isNull);
      expect(s.gasOverride.maxGwei, isNull);
    });
  });

  test('reset() returns state to defaults', () {
    final c = _container();
    addTearDown(c.dispose);
    c.read(sendNotifierProvider.notifier)
      ..setSelectedAsset(_ethAsset)
      ..setToAddress(_validAddress)
      ..setAmount('1')
      ..reset();

    final s = c.read(sendNotifierProvider);
    expect(s.toAddress, '');
    expect(s.amount, '');
    expect(s.selectedAsset, isNull);
    expect(s.status, SendStatus.idle);
  });
}
