import 'package:flutter/foundation.dart';

@immutable
class WatchedToken {
  const WatchedToken({
    required this.id,
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.balance,
    this.logoUrl = '',
    this.isPinned = false,
    this.isHidden = false,
    this.balanceUsd = '',
    this.priceUsd = '',
    this.change24hPct = '',
    this.changePositive = true,
    this.sparkline7d = const [],
    this.sparkline30d = const [],
  });

  final String id;
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final String balance;

  /// Logo URL stamped by the backend from the embedded Uniswap
  /// Default Token List. Empty for unverified contracts — UI then
  /// renders a letter avatar.
  final String logoUrl;

  // Pin / dashboard visibility
  final bool isPinned;

  /// True when the user hid this token. Hidden tokens stay in storage so the
  /// auto-seed dedup map doesn't re-add them — UI just filters them out.
  final bool isHidden;

  // Market data (may be empty if CoinGecko unavailable)
  final String balanceUsd; // "$123.45" or ""
  final String priceUsd; // "1.000000" or ""
  final String change24hPct; // "+5.23" or "-2.10"
  final bool changePositive;
  final List<double> sparkline7d;
  final List<double> sparkline30d;

  WatchedToken copyWith({bool? isPinned, bool? isHidden}) => WatchedToken(
    id: id,
    address: address,
    symbol: symbol,
    name: name,
    decimals: decimals,
    balance: balance,
    logoUrl: logoUrl,
    isPinned: isPinned ?? this.isPinned,
    isHidden: isHidden ?? this.isHidden,
    balanceUsd: balanceUsd,
    priceUsd: priceUsd,
    change24hPct: change24hPct,
    changePositive: changePositive,
    sparkline7d: sparkline7d,
    sparkline30d: sparkline30d,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WatchedToken && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
