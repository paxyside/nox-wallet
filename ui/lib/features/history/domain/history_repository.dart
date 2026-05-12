import 'package:nox/features/history/domain/transaction.dart';

export 'transaction.dart';

/// Abstract contract for the history data source.
abstract class HistoryRepository {
  /// Fetches a page of transactions.
  ///
  /// [cursor] — pagination cursor from the previous [HistoryPage.nextCursor].
  /// [limit]  — maximum number of items to return (default 20).
  Future<HistoryPage> getHistory({String cursor = '', int limit = 20});
}
