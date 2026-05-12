import 'package:nox/core/balance/balance_repository.dart';

class HomeState {
  const HomeState({required this.walletInfo, required this.balanceData, required this.gasStats});

  final WalletInfo walletInfo;
  final BalanceData balanceData;
  final GasStats gasStats;
}

class HomeUseCase {
  const HomeUseCase(this._repository);

  final BalanceRepository _repository;

  Future<HomeState> execute() async {
    final results = await Future.wait([
      _repository.getWallet(),
      _repository.getBalances(),
      _repository.getGasStats(),
    ]);
    return HomeState(
      walletInfo: results[0] as WalletInfo,
      balanceData: results[1] as BalanceData,
      gasStats: results[2] as GasStats,
    );
  }
}
