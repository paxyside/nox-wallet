import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/pagination.dart';
import 'package:nox/core/widgets/themed_dropdown.dart';
import 'package:nox/features/history/presentation/providers/history_provider.dart';
import 'package:nox/features/history/presentation/widgets/pending_tx_strip.dart';
import 'package:nox/features/history/presentation/widgets/transaction_tile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

// 5 tiles fit cleanly above the pagination footer once the search row was
// added to the header. Bumping back to 6 clipped the last tile.
const int _kPageSize = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    // Reset to page 0 whenever filters change.
    ref.listen<HistoryFilter>(historyFilterNotifierProvider, (prev, next) {
      if (_page != 0) setState(() => _page = 0);
    });

    final filter = ref.watch(historyFilterNotifierProvider);
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: historyAsync.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(total: 0, isLoading: true),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              ),
            ),
          ],
        ),
        error: (e, _) => _ErrorState(
          message: errorMessage(e),
          onRetry: () => ref.read(historyNotifierProvider.notifier).refresh(),
        ),
        data: (state) {
          final items = state.filtered(filter);

          // Clamp page to valid range when items count changes.
          final totalPages = items.isEmpty ? 1 : (items.length / _kPageSize).ceil();
          final page = _page.clamp(0, totalPages - 1);

          // Backend pagination is drained eagerly in HistoryNotifier on first
          // load — no per-page trigger needed here. The server's totalCount is
          // already reflected in pagination via state.hasMore.

          final start = page * _kPageSize;
          final end = (start + _kPageSize).clamp(0, items.length);
          final pageItems = items.sublist(start, end);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                total: state.totalCount,
                hasMore: false,
              ),
              const PendingTxStrip(),
              Expanded(
                child: items.isEmpty
                    ? _EmptyState(filter: filter)
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pageItems.length,
                              itemBuilder: (_, i) => TransactionTile(
                                // Key by tx hash so hover/expand state stays
                                // tied to the actual transaction across pages.
                                key: ValueKey(pageItems[i].txHash),
                                tx: pageItems[i],
                              ),
                            ),
                          ),
                          AppPagination(
                            current: page,
                            total: totalPages,
                            hasMore: state.hasMore,
                            loading: state.isLoadingMore,
                            onPage: (p) => setState(() => _page = p),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends ConsumerStatefulWidget {
  const _Header({
    required this.total,
    this.hasMore = false,
    this.isLoading = false,
  });

  final int total;
  final bool hasMore;
  final bool isLoading;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial sync from filter state — keeps the field populated if the user
    // navigates away and back.
    final initial = ref.read(historyFilterNotifierProvider).query;
    if (initial.isNotEmpty) _searchCtrl.text = initial;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterNotifierProvider);
    final notifier = ref.read(historyFilterNotifierProvider.notifier);
    final state = ref.watch(historyNotifierProvider).valueOrNull;
    final assets = state?.assets ?? const [];

    final countLabel = widget.isLoading
        ? ''
        : widget.total == 0
        ? ''
        : '${widget.total}${widget.hasMore ? '+' : ''} transactions';

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Row 1: title + direction toggle + dropdowns ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title + count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: AppTextStyles.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    countLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Direction pills
              _DirectionToggle(
                selected: filter.direction,
                onChanged: notifier.setDirection,
              ),

              const Spacer(),

              if (assets.isNotEmpty) ...[
                _TokenDropdown(
                  assets: assets,
                  selected: filter.asset,
                  onChanged: notifier.setAsset,
                ),
                const SizedBox(width: 12),
              ],

              _DateDropdown(
                selected: filter.dateRange,
                onChanged: notifier.setDateRange,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Row 2: search input — matches Tokens / Contacts headers ──────
          TextField(
            controller: _searchCtrl,
            onChanged: notifier.setQuery,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search by tx hash, address, or asset…',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textDisabled,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 16,
                color: context.colors.textSecondary,
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        notifier.setQuery('');
                      },
                    )
                  : null,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Direction toggle  (All / Sent / Received / Swaps)
// ─────────────────────────────────────────────────────────────────────────────

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({
    required this.selected,
    required this.onChanged,
  });

  final TxDirection selected;
  final ValueChanged<TxDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'All',
            active: selected == TxDirection.all,
            isFirst: true,
            onTap: () => onChanged(TxDirection.all),
          ),
          _Pill(
            label: 'Sent',
            active: selected == TxDirection.sent,
            onTap: () => onChanged(TxDirection.sent),
          ),
          _Pill(
            label: 'Received',
            active: selected == TxDirection.received,
            onTap: () => onChanged(TxDirection.received),
          ),
          _Pill(
            label: 'Swaps',
            active: selected == TxDirection.swaps,
            isLast: true,
            onTap: () => onChanged(TxDirection.swaps),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.horizontal(
      left: isFirst ? const Radius.circular(7) : Radius.zero,
      right: isLast ? const Radius.circular(7) : Radius.zero,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? context.colors.primary : Colors.transparent,
          borderRadius: radius,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? context.colors.textPrimary : context.colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Token dropdown  ("All Tokens" / specific symbol)
// ─────────────────────────────────────────────────────────────────────────────

class _TokenDropdown extends StatelessWidget {
  const _TokenDropdown({
    required this.assets,
    required this.selected,
    required this.onChanged,
  });

  final List<String> assets;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ThemedDropdown<String>(
      value: selected,
      width: 156,
      leadingIcon: Icons.toll_rounded,
      items: [
        const ThemedDropdownItem(value: '', label: 'All Tokens'),
        for (final a in assets) ThemedDropdownItem(value: a, label: a),
      ],
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date dropdown  ("Last 30 days" / "All time" / etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _DateDropdown extends StatelessWidget {
  const _DateDropdown({required this.selected, required this.onChanged});

  final DateRange selected;
  final ValueChanged<DateRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return ThemedDropdown<DateRange>(
      value: selected,
      width: 156,
      leadingIcon: Icons.calendar_today_rounded,
      items: [
        for (final r in DateRange.values) ThemedDropdownItem(value: r, label: r.label),
      ],
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final HistoryFilter filter;

  bool get _hasFilters =>
      filter.direction != TxDirection.all ||
      filter.asset.isNotEmpty ||
      filter.dateRange != DateRange.all;

  String get _message {
    if (filter.direction == TxDirection.sent) return 'No sent transactions.';
    if (filter.direction == TxDirection.received) {
      return 'No received transactions.';
    }
    if (filter.asset.isNotEmpty) return 'No ${filter.asset} transactions.';
    if (_hasFilters) return 'No transactions for this period.';
    return 'No transactions yet';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: context.colors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hasFilters
                ? 'Try changing the filters.'
                : 'Once you send or receive ETH, it will show up here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_hasFilters) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go(Routes.send),
              icon: const Icon(Icons.arrow_upward_rounded, size: 16),
              label: const Text('Send your first ETH'),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load history',
              style: AppTextStyles.h3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
