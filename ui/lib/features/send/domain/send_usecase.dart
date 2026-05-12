import 'package:nox/features/send/domain/send_repository.dart';

export 'send_repository.dart';

class SendUseCase {
  const SendUseCase(this._repository);

  final SendRepository _repository;

  Future<GasEstimate> getGasEstimate() => _repository.getGasEstimate();

  Future<TxResult> sendEth(String toAddress, String amount, {GasOverride gas = GasOverride.auto}) =>
      _repository.sendEth(toAddress, amount, gas: gas);

  Future<TxResult> sendToken(
    String toAddress,
    String tokenAddress,
    String amount, {
    GasOverride gas = GasOverride.auto,
  }) => _repository.sendToken(toAddress, tokenAddress, amount, gas: gas);
}
