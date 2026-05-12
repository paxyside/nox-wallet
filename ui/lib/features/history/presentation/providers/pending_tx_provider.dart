import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/features/history/data/pending_tx_repository.dart';

/// pendingTxsProvider polls ListPendingTxs every 3s. Pending transactions live
/// only in process memory on the backend, so a short poll is fine — the list
/// is typically empty and resolves within a block or two.
final AutoDisposeFutureProvider<List<PendingTxItem>> pendingTxsProvider =
    FutureProvider.autoDispose<List<PendingTxItem>>((ref) async {
      const repo = PendingTxGrpcRepository();

      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

      return repo.list();
    });
