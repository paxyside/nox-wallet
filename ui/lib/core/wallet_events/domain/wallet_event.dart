// Pure-Dart domain models for wallet events. No proto, no gRPC.

import 'package:flutter/foundation.dart';

enum WalletEventKind { gasAlert, lowBalance, transaction }

/// Unified wallet event — exactly one of the payload fields is non-null.
///
/// `id` and `isRead` carry the persisted-row metadata stamped by the
/// server-side `NotificationEnvelope`. Live stream events arrive with
/// `isRead=false` and an ID minted at the moment of persistence; events
/// that bypassed persistence (sink off, marshal failure) ship with
/// `id=""` — those are ephemeral and can't be marked or cleared, but
/// the UI can still render them.
@immutable
class WalletEvent {
  const WalletEvent({
    required this.kind,
    this.id = '',
    this.isRead = false,
    this.gasAlert,
    this.lowBalance,
    this.transaction,
  });

  final String id;
  final bool isRead;
  final WalletEventKind kind;
  final GasAlertEvent? gasAlert;
  final LowBalanceEvent? lowBalance;
  final TransactionEvent? transaction;

  WalletEvent copyWith({String? id, bool? isRead}) => WalletEvent(
    kind: kind,
    id: id ?? this.id,
    isRead: isRead ?? this.isRead,
    gasAlert: gasAlert,
    lowBalance: lowBalance,
    transaction: transaction,
  );
}

@immutable
class GasAlertEvent {
  const GasAlertEvent({
    required this.isSpike,
    required this.currentGwei,
    required this.previousGwei,
  });

  final bool isSpike;
  final String currentGwei;
  final String previousGwei;

  String get label => isSpike ? 'Gas spike' : 'Gas drop';

  String get description {
    final cur = double.tryParse(currentGwei) ?? 0;
    final prev = double.tryParse(previousGwei) ?? 0;
    final action = isSpike ? 'jumped to' : 'dropped to';
    if (prev == 0) return 'Base fee $action $currentGwei Gwei';
    final pct = ((cur - prev) / prev * 100).round();
    final sign = pct >= 0 ? '+' : '−'; // unicode minus for visual symmetry
    return 'Base fee $action $currentGwei Gwei ($sign${pct.abs()}%)';
  }
}

@immutable
class LowBalanceEvent {
  const LowBalanceEvent({required this.ethBalance, required this.ethBalanceWei});

  final String ethBalance;
  final String ethBalanceWei;
}

// ── Canonical transaction event ─────────────────────────────────────────────

/// Maps to the backend's TransactionEvent.Role. One value per
/// user-action — the UI uses this to pick a notification template and
/// to render the rich panel tile.
enum TxRole { unknown, sendEth, receiveEth, sendToken, receiveToken, swap, selfTransfer, approve }

@immutable
class AssetMovement {
  const AssetMovement({
    required this.symbol,
    required this.name,
    required this.contractAddress,
    required this.amount,
    required this.isOutgoing,
    required this.counterparty,
  });

  final String symbol;
  final String name;
  final String contractAddress; // empty = native ETH
  final String amount; // human-readable, decimals applied
  final bool isOutgoing;
  final String counterparty;

  /// "ETH" / "USDC" / "Unknown" — never an empty string.
  String get displaySymbol => symbol.isEmpty ? 'Unknown' : symbol;
}

@immutable
class TransactionEvent {
  const TransactionEvent({
    required this.txHash,
    required this.role,
    required this.movements,
    required this.isOurs,
    required this.blockNumber,
    required this.timestamp,
  });

  final String txHash;
  final TxRole role;
  final List<AssetMovement> movements;
  final bool isOurs;
  final int blockNumber;
  final DateTime timestamp;

  Iterable<AssetMovement> get outgoing => movements.where((m) => m.isOutgoing);
  Iterable<AssetMovement> get incoming => movements.where((m) => !m.isOutgoing);

  String get shortTxHash => txHash.length > 14
      ? '${txHash.substring(0, 8)}…${txHash.substring(txHash.length - 6)}'
      : txHash;
}

/// Repository abstraction for the wallet event stream.
abstract class WalletEventsRepository {
  /// Long-running stream of wallet events. Implementations should auto-reconnect
  /// on transient errors (the consumer treats this stream as infinite).
  Stream<WalletEvent> watch();
}
