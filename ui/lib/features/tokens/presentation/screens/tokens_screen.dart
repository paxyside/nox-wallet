import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/pagination.dart';
import 'package:nox/core/widgets/themed_dropdown.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:nox/features/tokens/presentation/widgets/add_token_dialog.dart';
import 'package:nox/features/tokens/presentation/widgets/token_list_tile.dart';

// ---------------------------------------------------------------------------
// Header widget — title + search + add (mirrors Contacts header)
// ---------------------------------------------------------------------------

class _TokensHeader extends ConsumerStatefulWidget {
  const _TokensHeader({required this.total});
  final int total;

  @override
  ConsumerState<_TokensHeader> createState() => _TokensHeaderState();
}

class _TokensHeaderState extends ConsumerState<_TokensHeader> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showAdd() => showAppDialog<void>(context: context, builder: (_) => const AddTokenDialog());

  @override
  Widget build(BuildContext context) {
    final totalValue = ref.watch(totalPortfolioValueProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title + count + total value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tokens', style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary)),
              // Always render subtitle line to keep column height stable.
              Row(
                children: [
                  if (widget.total > 0) ...[
                    Text(
                      '${widget.total} tracked',
                      style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                    ),
                    if (totalValue.isNotEmpty) ...[
                      Text(
                        ' · ',
                        style: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
                      ),
                      Text(
                        totalValue,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ] else
                    const Text('', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Search — grows to fill
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => ref.read(tokensSearchProvider.notifier).updateQuery(v),
              style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or symbol…',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
                prefixIcon: Icon(Icons.search, size: 16, color: context.colors.textSecondary),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 14, color: context.colors.textSecondary),
                        onPressed: () {
                          _ctrl.clear();
                          ref.read(tokensSearchProvider.notifier).clear();
                        },
                      )
                    : null,
                filled: false,
                fillColor: context.colors.surfaceHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  borderSide: BorderSide(color: context.colors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Visibility filter (Visible / Hidden / All)
          const _VisibilityButton(),

          const SizedBox(width: 12),

          // Sort dropdown
          _SortButton(),

          const SizedBox(width: 12),

          // Add button
          FilledButton.icon(
            onPressed: _showAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add token'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

const _kTokensPageSize = 5;

class TokensScreen extends ConsumerStatefulWidget {
  const TokensScreen({super.key});

  @override
  ConsumerState<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends ConsumerState<TokensScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    ref
      ..listenManual<String>(tokensSearchProvider, (prev, next) {
        if (mounted) setState(() => _page = 0);
      })
      ..listenManual<TokenSortField>(tokensSortProvider, (prev, next) {
        if (mounted) setState(() => _page = 0);
      })
      ..listenManual<TokenVisibility>(tokensVisibilityFilterProvider, (prev, next) {
        // Page count differs between Visible / Hidden / All — snapping
        // back to page 0 avoids showing an empty page if the user
        // jumped to e.g. page 3 of Visible then switched to Hidden
        // where there are 2 entries.
        if (mounted) setState(() => _page = 0);
      });
  }

  /// Hide or un-hide depending on the row's current state. Same handler
  /// for both directions — the expanded row's chip flips its label
  /// based on `token.isHidden` so the user sees the right verb.
  Future<void> _toggleHide(WatchedToken token) async {
    final newHidden = !token.isHidden;
    final label = token.symbol.isEmpty ? 'Token' : token.symbol;
    try {
      await ref.read(tokensNotifierProvider.notifier).hide(token.id, hidden: newHidden);
      if (mounted) {
        AppSnackBar.info(context, newHidden ? '$label hidden.' : '$label restored.');
      }
    } on Object catch (_) {
      if (mounted) {
        AppSnackBar.error(
          context,
          newHidden ? 'Failed to hide token.' : 'Failed to restore token.',
        );
      }
    }
  }

  Future<void> _confirmAndRemove(WatchedToken token) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'Remove token',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
        content: Text(
          'Remove ${token.symbol.isEmpty ? token.address : token.symbol} '
          'from your watched list?',
          style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: context.colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(tokensNotifierProvider.notifier).remove(token.id);
      } on Object catch (_) {
        if (mounted) {
          AppSnackBar.error(context, 'Failed to remove token. Please try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokensAsync = ref.watch(tokensNotifierProvider);
    final filtered = ref.watch(filteredTokensProvider);
    final query = ref.watch(tokensSearchProvider);
    final allTokens = tokensAsync.valueOrNull ?? [];

    final totalPages = (filtered.length / _kTokensPageSize).ceil();
    final safePage = totalPages == 0 ? 0 : _page.clamp(0, totalPages - 1);
    final start = safePage * _kTokensPageSize;
    final end = (start + _kTokensPageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <WatchedToken>[] : filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header — always shown ────────────────────────────────────────
          _TokensHeader(total: allTokens.length),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: tokensAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (_, _) => const _SkeletonTile(),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: context.colors.error, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load tokens',
                      style: AppTextStyles.bodyLarge.copyWith(color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      err.toString(),
                      style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.read(tokensNotifierProvider.notifier).refresh(),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (_) {
                // Empty — no tokens added at all
                if (allTokens.isEmpty) {
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
                            Icons.token_outlined,
                            color: context.colors.textSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tokens yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add ERC-20 tokens to track them.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => showAppDialog<void>(
                            context: context,
                            builder: (_) => const AddTokenDialog(),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Token'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: AppTextStyles.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty filtered list — copy depends on why it's empty:
                // search hit nothing vs visibility filter has no matches.
                if (filtered.isEmpty) {
                  final visibility = ref.watch(tokensVisibilityFilterProvider);
                  final hasSearch = query.isNotEmpty;
                  final (icon, message) = switch ((hasSearch, visibility)) {
                    (true, _) => (Icons.search_off, 'No tokens match "$query"'),
                    (false, TokenVisibility.hidden) => (
                      Icons.visibility_off_outlined,
                      'No hidden tokens. Hide one from a row to manage it here.',
                    ),
                    (false, _) => (Icons.search_off, 'No tokens to show'),
                  };
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 48, color: context.colors.textDisabled),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Paginated list
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pageItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final token = pageItems[index];
                    // Key by token.id so the per-tile expand state stays
                    // tied to the actual token, not the row position. Without
                    // a key, paginating from page 1 to 2 reuses the State of
                    // the row at index 0 — the new token at the top inherits
                    // the previous token's "expanded" flag.
                    return TokenListTile(
                      key: ValueKey(token.id),
                      token: token,
                      onHide: () => _toggleHide(token),
                      onRemove: () => _confirmAndRemove(token),
                    );
                  },
                );
              },
            ),
          ),

          // ── Pagination bar ───────────────────────────────────────────────
          if (totalPages > 1)
            AppPagination(
              current: safePage,
              total: totalPages,
              onPage: (p) => setState(() => _page = p),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visibility filter dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _VisibilityButton extends ConsumerWidget {
  const _VisibilityButton();

  static const Map<TokenVisibility, String> _labels = {
    TokenVisibility.visible: 'Visible',
    TokenVisibility.hidden: 'Hidden',
    TokenVisibility.all: 'All',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(tokensVisibilityFilterProvider);
    return ThemedDropdown<TokenVisibility>(
      value: current,
      width: 130,
      leadingIcon: Icons.visibility_outlined,
      items: [
        for (final entry in _labels.entries)
          ThemedDropdownItem(value: entry.key, label: entry.value),
      ],
      onChanged: (v) => ref.read(tokensVisibilityFilterProvider.notifier).select(v),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _SortButton extends ConsumerWidget {
  static const Map<TokenSortField, String> _labels = {
    TokenSortField.value: 'By value',
    TokenSortField.balance: 'By balance',
    TokenSortField.name: 'By name',
    TokenSortField.change: 'By 24h Δ',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(tokensSortProvider);
    return ThemedDropdown<TokenSortField>(
      value: current,
      width: 150,
      leadingIcon: Icons.sort_rounded,
      items: [
        for (final entry in _labels.entries)
          ThemedDropdownItem(value: entry.key, label: entry.value),
      ],
      onChanged: (v) => ref.read(tokensSortProvider.notifier).selectField(v),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton tile (shown during initial load)
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonTile extends StatefulWidget {
  const _SkeletonTile();

  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    unawaited(_ctrl.repeat(reverse: true));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final base = context.colors.surfaceHigh;
        final shine = context.colors.border;
        final color = Color.lerp(base, shine, _anim.value)!;

        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              // Circle avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              // Name + subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Sparkline placeholder
              Expanded(
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 20),
              // Price + change placeholder
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 11,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 42,
                    height: 16,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Balance placeholder
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 13,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 11,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
