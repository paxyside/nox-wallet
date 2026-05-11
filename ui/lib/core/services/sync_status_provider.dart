import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

/// Last successful timestamp of each background ping. Both fields are null
/// until the first response arrives.
@immutable
class SyncStatus {
  const SyncStatus({this.walletSynced, this.networkSynced});

  final DateTime? walletSynced;
  final DateTime? networkSynced;

  SyncStatus copyWith({DateTime? walletSynced, DateTime? networkSynced}) => SyncStatus(
    walletSynced: walletSynced ?? this.walletSynced,
    networkSynced: networkSynced ?? this.networkSynced,
  );
}

/// Polls the backend every 30 seconds via [BalanceRepository] and surfaces
/// connectivity status to the UI. Goes through the repository abstraction so
/// no proto/gRPC details leak into providers.
@Riverpod(keepAlive: true)
class SyncStatusNotifier extends _$SyncStatusNotifier {
  static const _interval = Duration(seconds: 30);

  Timer? _walletTimer;
  Timer? _networkTimer;

  @override
  SyncStatus build() {
    const repo = BalanceGrpcRepository();
    ref.onDispose(() {
      _walletTimer?.cancel();
      _networkTimer?.cancel();
    });

    // Kick off both pings immediately, then on a 30 s tick.
    unawaited(_pingWallet(repo));
    unawaited(_pingNetwork(repo));
    _walletTimer = Timer.periodic(_interval, (_) => _pingWallet(repo));
    _networkTimer = Timer.periodic(_interval, (_) => _pingNetwork(repo));

    return const SyncStatus();
  }

  Future<void> _pingWallet(BalanceRepository repo) async {
    try {
      await repo.getWallet();
      state = state.copyWith(walletSynced: DateTime.now());
    } on Object catch (_) {
      // Backend unreachable — keep last known timestamp.
    }
  }

  Future<void> _pingNetwork(BalanceRepository repo) async {
    try {
      await repo.getGasStats();
      state = state.copyWith(networkSynced: DateTime.now());
    } on Object catch (_) {
      // Network unreachable — keep last known timestamp.
    }
  }
}
