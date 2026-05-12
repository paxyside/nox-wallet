// Domain models and abstract repository for wallet balance data.

class WalletInfo {
  const WalletInfo({required this.address, required this.label});

  final String address;
  final String label;
}

class TokenBalance {
  const TokenBalance({
    required this.symbol,
    required this.name,
    required this.address,
    required this.balance,
    this.usdValue = '',
    this.logoUrl = '',
  });

  final String symbol;
  final String name;
  final String address;
  final String balance;
  final String usdValue;

  /// Logo URL from the embedded Uniswap Default Token List (stamped by
  /// the backend). Empty for unverified contracts — UI shows a letter
  /// avatar in that case.
  final String logoUrl;
}

class BalanceData {
  const BalanceData({
    required this.ethBalance,
    required this.tokens,
    this.ethUsdValue = '',
    this.ethLogoUrl = '',
  });

  final String ethBalance;
  final List<TokenBalance> tokens;
  final String ethUsdValue;

  /// Native asset logo URL (e.g. ETH on mainnet). Sourced from the
  /// network config's `native.logo_uri` — UI threads it into every
  /// `TokenIcon(symbol: 'ETH')` rendering instead of hardcoding.
  final String ethLogoUrl;
}

class GasStats {
  const GasStats({
    required this.baseFeeGwei,
    required this.maxFeeGwei,
    required this.blockNumber,
    this.chainId = 0,
  });

  final String baseFeeGwei;
  final String maxFeeGwei;
  final int blockNumber;

  /// EIP-155 chain ID; 1 = Ethereum mainnet. 0 means the backend hasn't
  /// reported it (older builds before the network status indicator).
  final int chainId;
}

abstract class BalanceRepository {
  Future<WalletInfo> getWallet();
  Future<BalanceData> getBalances();
  Future<GasStats> getGasStats();

  /// Returns `true` when a wallet is loaded on the backend, `false` when no
  /// wallet has been provisioned yet. Other errors (network, server) propagate.
  Future<bool> walletExists();
}
