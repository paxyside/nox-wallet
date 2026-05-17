import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nox/core/ens/ens_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/formatters.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/core/widgets/row_icon_button.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/history/domain/transaction.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _truncate(String hash, {int head = 6, int tail = 4}) {
  if (hash.length <= head + tail + 1) return hash;
  return '${hash.substring(0, head)}…${hash.substring(hash.length - tail)}';
}

extension on String {
  /// Returns null when the string is empty — keeps the `??` fallback chain
  /// in transaction_tile readable.
  String? nullIfEmpty() => isEmpty ? null : this;
}

final _exactTimeFmt = DateFormat('MMM d, HH:mm');

/// Formats a stored ETH gas-cost string (e.g. "0.00013405") for display,
/// stripping trailing zeros (e.g. "0.000134 ETH").
String _formatGasEth(String ethStr) {
  final val = double.tryParse(ethStr);
  if (val == null || val == 0) return '';
  // Keep up to 8 decimal places, strip trailing zeros.
  final trimmed = val
      .toStringAsFixed(8)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return '$trimmed ETH';
}

// ---------------------------------------------------------------------------
// Tile
// ---------------------------------------------------------------------------

class TransactionTile extends ConsumerStatefulWidget {
  const TransactionTile({required this.tx, super.key});

  final Transaction tx;

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setHover(bool v) {
    if (_hovered == v) return;
    setState(() => _hovered = v);
    if (v) {
      unawaited(_ctrl.forward());
    } else {
      unawaited(_ctrl.reverse());
    }
  }

  void _openEtherscan() => launchUrl(Uri.parse('https://etherscan.io/tx/${widget.tx.txHash}'));

  Future<void> _copyHash() async {
    await Clipboard.setData(ClipboardData(text: widget.tx.txHash));
    if (mounted) AppSnackBar.success(context, 'Transaction hash copied.');
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final incoming = tx.isIncoming;
    final isSwap = tx.isSwap;

    // Tint per transaction kind. Sent uses `warning` (amber) instead
    // of `error` (red) — red on every outgoing tx screamed "danger"
    // when the user was just making a normal transfer; amber reads
    // as "money leaving" without alarm. Mirrors the menubar
    // activity feed so the same row visual language carries across
    // both surfaces.
    final accentColor = isSwap
        ? context.colors.primary
        : incoming
        ? context.colors.success
        : context.colors.warning;

    final directionLabel = isSwap ? 'Swap' : (incoming ? 'Received' : 'Sent');
    final directionIcon = isSwap
        ? Icons.swap_horiz_rounded
        : incoming
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    // Display priority for each side: contact name → ENS reverse name →
    // truncated 0x…. ENS lookups are cached at app scope (see ensReverse),
    // so subsequent renders + scrolls are free.
    final contacts = ref.watch(contactsNotifierProvider).valueOrNull ?? [];
    String? contactNameFor(String address) {
      final lower = address.toLowerCase();
      return contacts.where((c) => c.address.toLowerCase() == lower).firstOrNull?.name;
    }

    final fromName = contactNameFor(tx.from);
    final toName = contactNameFor(tx.to);

    String? ensNameFor(String address) =>
        ref.watch(ensReverseProvider(address)).valueOrNull?.nullIfEmpty();

    final fromDisplay = fromName ?? ensNameFor(tx.from) ?? _truncate(tx.from);
    final toDisplay = toName ?? ensNameFor(tx.to) ?? _truncate(tx.to);
    final assetLabel = isSwap
        ? '${tx.tokenInSym.toUpperCase()} → ${tx.tokenOutSym.toUpperCase()}'
        : (tx.asset.isEmpty ? 'ETH' : tx.asset).toUpperCase();
    final valueSign = incoming ? '+' : '-';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: _openEtherscan,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final t = _anim.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                boxShadow: t > 0
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.07 * t),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(context.colors.surface, context.colors.surfaceHigh, t),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color.lerp(
                      context.colors.border,
                      accentColor.withValues(alpha: 0.35),
                      t,
                    )!,
                  ),
                ),
                child: Stack(
                  children: [
                    // ── Colored left accent bar ──────────────────────────────
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        color: Color.lerp(accentColor.withValues(alpha: 0.45), accentColor, t),
                      ),
                    ),

                    // ── Main content ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(19, 10, 14, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── LEFT COLUMN ───────────────────────────────────
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _TxIcon(icon: directionIcon, color: accentColor, glowValue: t),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Direction label + asset badge
                                      Row(
                                        children: [
                                          Text(
                                            directionLabel,
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: context.colors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          _AssetBadge(assetLabel),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      // For swap rows, the raw `from` is the
                                      // Uniswap V3 pool address (one per pair)
                                      // — useless to render verbatim. Since
                                      // our app only routes swaps via Uniswap
                                      // V3 today, label it generically. Future:
                                      // pass a router/protocol field through
                                      // the tx model and look it up here.
                                      Text(
                                        isSwap
                                            ? 'via Uniswap V3 · $toDisplay'
                                            : '$fromDisplay → $toDisplay',
                                        style: AppTextStyles.monoSmall.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      // Exact date + block
                                      Text(
                                        '${_exactTimeFmt.format(tx.blockTime.toLocal())} · Block ${tx.blockNum}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: context.colors.textDisabled,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ── MIDDLE COLUMN — gas fee (fixed width, always) ──
                          SizedBox(
                            width: 130,
                            child: tx.gasFeeEth.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Gas',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: context.colors.textDisabled,
                                        ),
                                      ),
                                      if (tx.gasFeeUsd.isNotEmpty)
                                        Text(
                                          tx.gasFeeUsd,
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: context.colors.textPrimary,
                                          ),
                                        ),
                                      Text(
                                        _formatGasEth(tx.gasFeeEth),
                                        style: AppTextStyles.monoSmall.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(width: 12),

                          // ── RIGHT COLUMN — fixed width: [amount+usd | btns] ─
                          SizedBox(
                            width: 240,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Amount + USD — takes remaining space, right-aligned
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: isSwap
                                        ? [
                                            MaskableText(
                                              '-${formatAmountCompact(tx.tokenInValue)} ${tx.tokenInSym.toUpperCase()}',
                                              style: AppTextStyles.labelLarge.copyWith(
                                                color: context.colors.error,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                            const SizedBox(height: 2),
                                            MaskableText(
                                              '+${formatAmountCompact(tx.tokenOutValue)} ${tx.tokenOutSym.toUpperCase()}',
                                              style: AppTextStyles.labelLarge.copyWith(
                                                color: context.colors.success,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ]
                                        : [
                                            MaskableText(
                                              '$valueSign${formatAmountCompact(tx.value)} $assetLabel',
                                              style: AppTextStyles.labelLarge.copyWith(
                                                // Received shows green (positive money
                                                // event); sent uses textPrimary so the
                                                // amber-tinted icon/bar do the "money
                                                // leaving" signalling and the number
                                                // itself reads as a neutral fact.
                                                color: incoming
                                                    ? context.colors.success
                                                    : context.colors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                shadows: incoming
                                                    ? [
                                                        Shadow(
                                                          color: accentColor.withValues(
                                                            alpha: 0.30 + 0.35 * t,
                                                          ),
                                                          blurRadius: 8,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                            if (tx.valueUsd.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              MaskableText(
                                                '≈ ${tx.valueUsd}',
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  color: context.colors.textSecondary,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ],
                                  ),
                                ),
                                // Buttons — fixed width, always visible
                                const SizedBox(width: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RowIconButton(
                                      icon: Icons.open_in_new_rounded,
                                      tooltip: 'View on Etherscan',
                                      onTap: _openEtherscan,
                                    ),
                                    const SizedBox(width: 4),
                                    RowIconButton(
                                      icon: Icons.copy_rounded,
                                      tooltip: 'Copy tx hash',
                                      onTap: _copyHash,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction icon with glow
// ---------------------------------------------------------------------------

class _TxIcon extends StatelessWidget {
  const _TxIcon({required this.icon, required this.color, required this.glowValue});

  final IconData icon;
  final Color color;
  final double glowValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10 + 0.06 * glowValue),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12 + 0.20 * glowValue),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15 + 0.20 * glowValue)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

// ---------------------------------------------------------------------------
// Asset badge
// ---------------------------------------------------------------------------

class _AssetBadge extends StatelessWidget {
  const _AssetBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
