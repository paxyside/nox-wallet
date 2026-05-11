import 'dart:async';

import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';
import 'package:wallet_proto/wallet/event/event.pb.dart' as $pb;
import 'package:wallet_proto/wallet/service.pb.dart' as $svc;
import 'package:wallet_proto/wallet/service.pb.dart';

/// gRPC-backed implementation of [WalletEventsRepository]. Maps proto payloads
/// to the domain types and reconnects on transient errors.
class WalletEventsGrpcRepository implements WalletEventsRepository {
  const WalletEventsGrpcRepository();

  @override
  Stream<WalletEvent> watch() async* {
    final stub = GrpcClient.instance.stub;

    while (true) {
      try {
        final stream = stub.watchEvents(WatchEventsRequest());
        await for (final env in stream) {
          if (!env.hasEvent()) continue;
          yield _eventFromProto(env.event).copyWith(
            id: env.id,
            isRead: env.isRead,
          );
        }
      } on Object catch (_) {
        // Stream ended or backend restarted — wait and reconnect.
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    }
  }
}

/// Maps a `NotificationEnvelope` (id + is_read + event) returned by
/// `ListNotifications` into the domain WalletEvent — same shape the
/// live stream produces. Used only by the hydration path.
WalletEvent walletEventFromEnvelope($svc.NotificationEnvelope env) =>
    _eventFromProto(env.event).copyWith(id: env.id, isRead: env.isRead);

/// Public alias so other providers (notification_history backfill) can
/// reuse the same proto → domain mapping without re-implementing the
/// switch.
WalletEvent walletEventFromProto($pb.WalletEvent proto) => _eventFromProto(proto);

WalletEvent _eventFromProto($pb.WalletEvent proto) {
  if (proto.hasGasAlert()) {
    final p = proto.gasAlert;
    return WalletEvent(
      kind: WalletEventKind.gasAlert,
      gasAlert: GasAlertEvent(
        isSpike: p.type == $pb.GasAlertEvent_AlertType.SPIKE,
        currentGwei: p.currentGwei,
        previousGwei: p.previousGwei,
      ),
    );
  }
  if (proto.hasLowBalance()) {
    final p = proto.lowBalance;
    return WalletEvent(
      kind: WalletEventKind.lowBalance,
      lowBalance: LowBalanceEvent(
        ethBalance: p.ethBalance,
        ethBalanceWei: p.ethBalanceWei,
      ),
    );
  }
  if (proto.hasTransaction()) {
    return WalletEvent(
      kind: WalletEventKind.transaction,
      transaction: _transactionFromProto(proto.transaction),
    );
  }
  throw StateError('WalletEvent has no known payload');
}

TransactionEvent _transactionFromProto($pb.TransactionEvent p) {
  // Treat 1970-01-01 (proto zero value) the same as a missing field —
  // proto3 doesn't distinguish "field present with zero value" from
  // "field unset" via hasTimestamp() when timestamppb.New(zero) was
  // sent. Without this guard the panel renders "Jan 1" for events the
  // backend marshalled with a zero blockTimestamp.
  DateTime resolvedTs;
  if (p.hasTimestamp()) {
    final raw = p.timestamp.toDateTime();
    resolvedTs = raw.millisecondsSinceEpoch <= 0 ? DateTime.now() : raw;
  } else {
    resolvedTs = DateTime.now();
  }

  return TransactionEvent(
    txHash: p.txHash,
    role: _roleFromProto(p.role),
    movements: p.movements
        .map(
          (m) => AssetMovement(
            symbol: m.symbol,
            name: m.name,
            contractAddress: m.contractAddress,
            amount: m.amount,
            isOutgoing: m.isOutgoing,
            counterparty: m.counterparty,
          ),
        )
        .toList(),
    isOurs: p.isOurs,
    blockNumber: p.blockNumber.toInt(),
    timestamp: resolvedTs,
  );
}

TxRole _roleFromProto($pb.TransactionEvent_Role r) {
  switch (r) {
    case $pb.TransactionEvent_Role.SEND_ETH:
      return TxRole.sendEth;
    case $pb.TransactionEvent_Role.RECEIVE_ETH:
      return TxRole.receiveEth;
    case $pb.TransactionEvent_Role.SEND_TOKEN:
      return TxRole.sendToken;
    case $pb.TransactionEvent_Role.RECEIVE_TOKEN:
      return TxRole.receiveToken;
    case $pb.TransactionEvent_Role.SWAP:
      return TxRole.swap;
    case $pb.TransactionEvent_Role.SELF_TRANSFER:
      return TxRole.selfTransfer;
    case $pb.TransactionEvent_Role.APPROVE:
      return TxRole.approve;
    case $pb.TransactionEvent_Role.UNKNOWN:
      return TxRole.unknown;
  }
  return TxRole.unknown;
}
