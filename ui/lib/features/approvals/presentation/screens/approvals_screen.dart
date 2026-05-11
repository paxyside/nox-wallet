import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/pagination.dart';
import 'package:nox/features/approvals/domain/approval.dart';
import 'package:nox/features/approvals/presentation/providers/approvals_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// 6 tiles fit cleanly on the standard window height before the paginator.
const int _kPageSize = 6;

// ─────────────────────────────────────────────────────────────────────────────
// Revoke approvals screen — security view of every active ERC-20 allowance
// the wallet has granted to known DEX routers. Each row offers a one-click
// revoke (= approve(spender, 0)) and a view-on-etherscan link.
// ─────────────────────────────────────────────────────────────────────────────

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(approvalsNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            count: async.valueOrNull?.length ?? 0,
            isLoading: async.isLoading,
            onRefresh: () => ref.read(approvalsNotifierProvider.notifier).refresh(),
          ),
          Expanded(
            child: async.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: context.colors.primary,
                ),
              ),
              error: (e, _) => _ErrorState(
                message: errorMessage(e),
                onRetry: () => ref.read(approvalsNotifierProvider.notifier).refresh(),
              ),
              data: (items) {
                if (items.isEmpty) return const _EmptyState();

                // Clamp page to valid range when items shrink (e.g. after a
                // revoke removed the last row of the current page).
                final totalPages = (items.length / _kPageSize).ceil();
                final page = _page.clamp(0, totalPages - 1);
                final start = page * _kPageSize;
                final end = (start + _kPageSize).clamp(0, items.length);
                final pageItems = items.sublist(start, end);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
                        itemCount: pageItems.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ApprovalTile(
                          key: ValueKey(pageItems[i].id),
                          approval: pageItems[i],
                        ),
                      ),
                    ),
                    if (totalPages > 1)
                      AppPagination(
                        current: page,
                        total: totalPages,
                        onPage: (p) => setState(() => _page = p),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.isLoading,
    required this.onRefresh,
  });

  final int count;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Approvals',
                style: AppTextStyles.h2.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                isLoading
                    ? 'Scanning known DEX routers…'
                    : count == 0
                    ? 'No active allowances'
                    : '$count active ${count == 1 ? 'approval' : 'approvals'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
              side: BorderSide(color: context.colors.border),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ApprovalTile extends ConsumerStatefulWidget {
  const _ApprovalTile({required this.approval, super.key});

  final TokenApproval approval;

  @override
  ConsumerState<_ApprovalTile> createState() => _ApprovalTileState();
}

class _ApprovalTileState extends ConsumerState<_ApprovalTile> {
  bool _revoking = false;

  Future<void> _onRevoke() async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'Revoke approval?',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
        content: Text(
          'Submit an on-chain transaction to set ${widget.approval.tokenSymbol} '
          'allowance for ${widget.approval.spenderLabel} to zero. '
          'This costs gas.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _revoking = true);
    try {
      final hash = await ref
          .read(approvalsNotifierProvider.notifier)
          .revoke(widget.approval.tokenAddress, widget.approval.spender);
      if (mounted) {
        AppSnackBar.successWithLink(context, 'Approval revoked.', hash);
      }
    } on Object catch (e) {
      if (mounted) AppSnackBar.error(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _revoking = false);
    }
  }

  Future<void> _openExplorer() async {
    await launchUrl(
      Uri.parse('https://etherscan.io/address/${widget.approval.spender}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.approval;
    final isUnlimited = a.amountHuman == 'Unlimited';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Token avatar (CDN logo from Alchemy, fallback to letter) ─────
          _TokenAvatar(symbol: a.tokenSymbol, logoUrl: a.tokenLogoUrl),
          const SizedBox(width: 12),

          // ── Token + spender info ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      a.tokenSymbol,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlimited
                            ? context.colors.error.withValues(alpha: 0.1)
                            : context.colors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isUnlimited
                              ? context.colors.error.withValues(alpha: 0.4)
                              : context.colors.border,
                        ),
                      ),
                      child: Text(
                        a.amountHuman,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isUnlimited ? context.colors.error : context.colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Granted to ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.textDisabled,
                      ),
                    ),
                    Text(
                      a.spenderLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: a.spender),
                        );
                        if (context.mounted) {
                          AppSnackBar.info(context, 'Spender address copied.');
                        }
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        size: 12,
                        color: context.colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          IconButton(
            onPressed: _openExplorer,
            tooltip: 'View spender on Etherscan',
            icon: Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _revoking ? null : _onRevoke,
            icon: _revoking
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.textPrimary,
                    ),
                  )
                : const Icon(Icons.block_rounded, size: 14),
            label: Text(_revoking ? 'Revoking…' : 'Revoke'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.colors.error.withValues(
                alpha: 0.4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTextStyles.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Token avatar — CDN logo with letter-fallback
// ─────────────────────────────────────────────────────────────────────────────

class _TokenAvatar extends StatelessWidget {
  const _TokenAvatar({required this.symbol, required this.logoUrl});

  final String symbol;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = _LetterAvatar(symbol: symbol);

    if (logoUrl.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        logoUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        // 404 / network failure → silently fall back to the letter avatar.
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
      ),
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1).toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 32,
              color: context.colors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No active approvals',
            style: AppTextStyles.h3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 360,
            child: Text(
              "You haven't granted any active allowances to known DEX "
              'routers. Approvals appear here after the first swap of a '
              'given ERC-20 token.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: context.colors.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
              side: BorderSide(color: context.colors.border),
            ),
          ),
        ],
      ),
    );
  }
}
