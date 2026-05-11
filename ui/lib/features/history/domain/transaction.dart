/// Domain entity representing a single history transaction.
class Transaction {
  const Transaction({
    required this.txHash,
    required this.from,
    required this.to,
    required this.asset,
    required this.value,
    required this.category,
    required this.blockNum,
    required this.blockTime,
    required this.walletAddress,
    this.gasFeeEth = '',
    this.gasFeeUsd = '',
    this.valueUsd = '',
    this.isSwap = false,
    this.tokenInSym = '',
    this.tokenInValue = '',
    this.tokenOutSym = '',
    this.tokenOutValue = '',
  });

  final String txHash;
  final String from;
  final String to;
  final String asset;
  final String value;
  final String category;
  final int blockNum;
  final DateTime blockTime;

  /// The address of the current wallet — used to derive direction.
  final String walletAddress;

  /// Gas fee in ETH (empty if not yet fetched from receipt).
  final String gasFeeEth;

  /// Gas fee in USD (empty if not yet fetched from receipt).
  final String gasFeeUsd;

  /// USD equivalent of the transaction value (empty if price unavailable).
  final String valueUsd;

  /// True when the server merged two same-hash legs that crossed a known DEX
  /// router into one synthetic swap entry.
  final bool isSwap;

  /// Sent token symbol on a swap (e.g. "USDC"). Empty unless [isSwap].
  final String tokenInSym;

  /// Sent token amount, human-readable. Empty unless [isSwap].
  final String tokenInValue;

  /// Received token symbol on a swap (e.g. "USDT"). Empty unless [isSwap].
  final String tokenOutSym;

  /// Received token amount, human-readable. Empty unless [isSwap].
  final String tokenOutValue;

  /// Returns true when this wallet is the recipient of the transaction.
  bool get isIncoming => to.toLowerCase() == walletAddress.toLowerCase();
}

/// A single page of history items returned from the repository.
class HistoryPage {
  const HistoryPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    this.totalCount = 0,
  });

  final List<Transaction> items;
  final String nextCursor;
  final bool hasMore;

  /// Total number of transactions in the DB for this address.
  final int totalCount;
}
