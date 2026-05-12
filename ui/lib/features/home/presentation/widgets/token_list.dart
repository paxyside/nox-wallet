import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:nox/features/tokens/presentation/widgets/add_token_dialog.dart';

class TokenList extends ConsumerWidget {
  const TokenList({required this.balanceData, super.key});

  final BalanceData balanceData;

  void _showAddToken(BuildContext context) {
    unawaited(showAppDialog<void>(context: context, builder: (_) => const AddTokenDialog()));
  }

  // Dashboard's compact list shows ERC-20 tokens only (ETH lives in the
  // header card). Up to 3 entries, ordered: pinned first, then by USD desc.
  static const _maxErc20 = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(tokensNotifierProvider);
    final List<TokenBalance> visibleTokens;

    if (watchedAsync.hasValue && watchedAsync.value!.isNotEmpty) {
      // Sort: pinned first, then by USD value descending.
      final sorted = List<WatchedToken>.from(watchedAsync.value!)
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          final aUsd = double.tryParse(a.balanceUsd.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final bUsd = double.tryParse(b.balanceUsd.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return bUsd.compareTo(aUsd);
        });

      visibleTokens = sorted
          .take(_maxErc20)
          .map(
            (w) => TokenBalance(
              symbol: w.symbol,
              name: w.name,
              address: w.address,
              balance: w.balance,
              usdValue: w.balanceUsd,
            ),
          )
          .toList();
    } else {
      visibleTokens = balanceData.tokens.take(_maxErc20).toList();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.surfaceHigh, context.colors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
            child: Text(
              'Tokens',
              style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
            ),
          ),
          Divider(height: 1, color: context.colors.border),

          // ── ERC-20 rows (up to 3, pinned-first / USD desc) ──────
          for (int i = 0; i < visibleTokens.length; i++) ...[
            _TokenRow(token: visibleTokens[i]),
            if (i < visibleTokens.length - 1)
              Divider(height: 1, indent: 20, endIndent: 20, color: context.colors.border),
          ],

          // ── Empty state ──────────────────────────────────────────
          if (visibleTokens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.token_outlined, size: 36, color: context.colors.textDisabled),
                  const SizedBox(height: 10),
                  Text(
                    'No tokens yet',
                    style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),

          // ── Add Token button ─────────────────────────────────────
          Divider(height: 1, color: context.colors.border),
          _AddTokenButton(onTap: () => _showAddToken(context)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERC-20 token row
// ─────────────────────────────────────────────────────────────────────────────

class _TokenRow extends StatefulWidget {
  const _TokenRow({required this.token});
  final TokenBalance token;

  @override
  State<_TokenRow> createState() => _TokenRowState();
}

class _TokenRowState extends State<_TokenRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.token;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [context.colors.primary.withValues(alpha: 0.08), Colors.transparent],
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Row(
          children: [
            TokenIcon(symbol: t.symbol, logoUrl: t.logoUrl, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.symbol.toUpperCase(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    t.name,
                    style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MaskableText(
                  t.balance,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (t.usdValue.isNotEmpty)
                  MaskableText(
                    t.usdValue,
                    style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// + Add Token button
// ─────────────────────────────────────────────────────────────────────────────

class _AddTokenButton extends StatefulWidget {
  const _AddTokenButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddTokenButton> createState() => _AddTokenButtonState();
}

class _AddTokenButtonState extends State<_AddTokenButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hovered ? context.colors.primary.withValues(alpha: 0.05) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: _hovered ? context.colors.primaryLight : context.colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Add Token',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _hovered ? context.colors.primaryLight : context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
