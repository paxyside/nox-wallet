import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/row_icon_button.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/approvals/presentation/providers/approvals_provider.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/widgets/token_change_badge.dart';
import 'package:nox/features/tokens/presentation/widgets/token_sparkline.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Timeframe enum (per-tile state, not a provider)
// ─────────────────────────────────────────────────────────────────────────────

enum TokenTimeframe { d1, d7, d30 }

// ─────────────────────────────────────────────────────────────────────────────
// Main row
// ─────────────────────────────────────────────────────────────────────────────

class TokenListTileMainRow extends ConsumerWidget {
  const TokenListTileMainRow({
    required this.token,
    required this.hovered,
    required this.tf,
    required this.sparkline,
    required this.onOpenDetails,
    required this.onPin,
    required this.onTimeframe,
    super.key,
  });

  final WatchedToken token;
  final bool hovered;
  final TokenTimeframe tf;
  final List<double> sparkline;
  final VoidCallback onOpenDetails;
  final VoidCallback onPin;
  final ValueChanged<TokenTimeframe> onTimeframe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = token;
    final hasMarket = t.priceUsd.isNotEmpty;
    // "0.00" / "+0.00" / "-0.00" → neutral grey. Anything else gets a
    // green/red depending on `changePositive`. This avoids the misleading
    // red-arrow-zero combination that appears when the price feed reports
    // an exactly-flat 24h change.
    final isFlatChange = t.change24hPct.replaceAll(RegExp(r'[+\-]'), '') == '0.00';
    final changeColor = isFlatChange
        ? context.colors.textSecondary
        : t.changePositive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Pin star ────────────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: (hovered || t.isPinned) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Tooltip(
              message: t.isPinned ? 'Unpin from dashboard' : 'Pin to dashboard',
              child: GestureDetector(
                onTap: onPin,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    t.isPinned ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: t.isPinned ? const Color(0xFFF59E0B) : context.colors.textDisabled,
                  ),
                ),
              ),
            ),
          ),

          // ── Icon ────────────────────────────────────────────────────────────
          TokenIcon(symbol: t.symbol, logoUrl: t.logoUrl, size: 40),
          const SizedBox(width: 12),

          // ── Name ────────────────────────────────────────────────────────────
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      t.symbol.toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  t.name,
                  style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Sparkline + (timeframe toggle ⟶ change badge ⟶ price inline) ──
          // Chart, timeframe toggle, change %, and price all read as one
          // unit. Price used to sit in its own column to the right which
          // made the eye jump — now it's part of the same component.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasMarket && sparkline.isNotEmpty)
                    TokenSparkline(points: sparkline, positive: t.changePositive, height: 24)
                  else
                    const SizedBox(height: 24),
                  const SizedBox(height: 4),
                  if (hasMarket)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TfToggle(current: tf, onChanged: onTimeframe),
                        const SizedBox(width: 8),
                        TokenChangeBadge(
                          change: t.change24hPct,
                          positive: t.changePositive,
                          color: changeColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPrice(t.priceUsd),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ── Balance ─────────────────────────────────────────────────────────
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MaskableText(
                  t.balance.isEmpty ? '—' : _truncBalance(t.balance),
                  style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (t.balanceUsd.isNotEmpty)
                  MaskableText(
                    t.balanceUsd,
                    style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Approval indicator + kebab ─────────────────────────────────────
          // Subtle shield badge when this token has an active approval —
          // lets the user audit at a glance instead of opening every
          // drawer. Tooltip explains. Single "..." opens the details
          // drawer (Send / Swap / Hide / Remove / Revoke all live in there
          // now). Inline action buttons used to fill this column.
          _ApprovalIndicator(tokenAddress: t.address, ref: ref),
          const SizedBox(width: 6),
          RowIconButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'Details',
            onTap: onOpenDetails,
          ),
        ],
      ),
    );
  }

  String _formatPrice(String raw) {
    final v = double.tryParse(raw) ?? 0;
    if (v == 0) return '';
    if (v >= 1000) return '\$${v.toStringAsFixed(0)}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    if (v >= 0.01) return '\$${v.toStringAsFixed(4)}';
    return '\$${v.toStringAsFixed(6)}';
  }

  String _truncBalance(String raw) {
    final v = double.tryParse(raw) ?? 0;
    if (v == 0) return '0';
    final fixed = v >= 1000
        ? v.toStringAsFixed(2)
        : v >= 1
        ? v.toStringAsFixed(4)
        : v.toStringAsFixed(6);
    final trimmed = fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (trimmed != '0') return trimmed;
    // 6-decimal precision rounded to "0" but the raw value is non-zero —
    // tiny dust balance (e.g. 3e-7 WETH). Expand to 12 decimals so the
    // figure shows accurately instead of a misleading "0".
    final tiny = v
        .toStringAsFixed(12)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return tiny == '0' ? '~0' : tiny;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeframe toggle (1D / 7D / 30D)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Approval indicator — small amber/warning shield next to the kebab when the
// token has at least one active allowance granted. Tooltip surfaces the count.
// Invisible when there are no approvals so the column stays uncluttered.
// ─────────────────────────────────────────────────────────────────────────────

class _ApprovalIndicator extends StatelessWidget {
  const _ApprovalIndicator({required this.tokenAddress, required this.ref});

  final String tokenAddress;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final asyncApprovals = ref.watch(approvalsNotifierProvider);
    final matching = asyncApprovals.valueOrNull
        ?.where((a) => a.tokenAddress.toLowerCase() == tokenAddress.toLowerCase())
        .toList();

    if (matching == null || matching.isEmpty) {
      // Reserve the same width as the visible indicator so neighbouring
      // kebab buttons sit at the same x-coord regardless of approval
      // state. Otherwise rows with/without approval would shimmy.
      return const SizedBox(width: 18);
    }

    final hasUnlimited = matching.any(
      (a) => a.amountHuman.toLowerCase().contains('unlimited'),
    );
    final accent = hasUnlimited ? col.error : const Color(0xFFF59E0B); // amber

    return Tooltip(
      message: hasUnlimited
          ? '${matching.length} active approval${matching.length == 1 ? '' : 's'} — at least one is unlimited'
          : '${matching.length} active approval${matching.length == 1 ? '' : 's'}',
      waitDuration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: 18,
        child: Icon(Icons.shield_outlined, size: 16, color: accent),
      ),
    );
  }
}

class _TfToggle extends StatelessWidget {
  const _TfToggle({required this.current, required this.onChanged});

  final TokenTimeframe current;
  final ValueChanged<TokenTimeframe> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TokenTimeframe.values.map((tf) {
          final active = tf == current;
          return GestureDetector(
            onTap: () => onChanged(tf),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: active ? context.colors.primary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                switch (tf) {
                  TokenTimeframe.d1 => '1D',
                  TokenTimeframe.d7 => '7D',
                  TokenTimeframe.d30 => '30D',
                },
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? context.colors.primary : context.colors.textDisabled,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
