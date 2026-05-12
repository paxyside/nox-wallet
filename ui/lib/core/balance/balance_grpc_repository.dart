import 'package:grpc/grpc.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/network/grpc_client.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

class BalanceGrpcRepository implements BalanceRepository {
  const BalanceGrpcRepository();

  @override
  Future<WalletInfo> getWallet() async {
    final response = await GrpcClient.instance.stub.getWallet(GetWalletRequest());
    return WalletInfo(address: response.wallet.address, label: response.wallet.label);
  }

  @override
  Future<BalanceData> getBalances() async {
    final request = GetBalancesRequest()..withTokens = true;
    final response = await GrpcClient.instance.stub.getBalances(request);
    final tokens = response.tokens
        .map(
          (t) => TokenBalance(
            symbol: t.symbol,
            name: t.name,
            address: t.address,
            balance: t.balance,
            usdValue: t.usdValue,
            logoUrl: t.logoUrl,
          ),
        )
        .toList();
    return BalanceData(
      ethBalance: response.ethBalance,
      tokens: tokens,
      ethUsdValue: response.ethUsdValue,
      ethLogoUrl: response.ethLogoUrl,
    );
  }

  @override
  Future<bool> walletExists() async {
    try {
      await GrpcClient.instance.stub.getWallet(GetWalletRequest());
      return true;
    } on GrpcError catch (e) {
      if (e.code == StatusCode.notFound) return false;
      rethrow;
    }
  }

  @override
  Future<GasStats> getGasStats() async {
    final response = await GrpcClient.instance.stub.getGasFees(GetGasFeesRequest());
    return GasStats(
      baseFeeGwei: response.fees.baseFeeGwei,
      maxFeeGwei: response.fees.maxFeeGwei,
      blockNumber: response.fees.blockNumber.toInt(),
      chainId: response.fees.chainId.toInt(),
    );
  }
}
