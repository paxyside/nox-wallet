import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/features/history/data/history_grpc_repository.dart';
import 'package:nox/features/history/domain/transaction.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_activity_provider.g.dart';

/// Loads up to 5 most recent transactions for the dashboard.
///
/// We over-fetch (`limit: 12`) because the server collapses two same-hash
/// swap legs into a single merged entry — asking for 5 raw rows can yield
/// only ~3 visible items. 12 raw rows comfortably covers 5 merged entries
/// even when most of them are swaps.
///
/// Depends on [homeDataProvider] for the wallet address — refreshes together.
@riverpod
Future<List<Transaction>> recentActivity(Ref ref) async {
  final homeAsync = ref.watch(homeDataProvider);
  final walletAddress = homeAsync.valueOrNull?.walletInfo.address ?? '';
  if (walletAddress.isEmpty) return [];

  final repo = HistoryGrpcRepository(walletAddress: walletAddress);
  final page = await repo.getHistory(limit: 12);
  return page.items.take(5).toList(growable: false);
}
