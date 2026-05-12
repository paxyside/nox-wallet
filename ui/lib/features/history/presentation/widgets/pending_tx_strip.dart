import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/features/history/data/pending_tx_repository.dart';
import 'package:nox/features/history/data/replacement_repository.dart';
import 'package:nox/features/history/presentation/providers/history_provider.dart';
import 'package:nox/features/history/presentation/providers/pending_tx_provider.dart';

/// Renders broadcast-but-not-yet-mined transactions above the confirmed
/// history. Each row mimics the visual language of a confirmed
/// `TransactionTile` (same margin, border-radius, accent bar) so the
/// list reads as one continuous timeline; the tier accent is the warning
/// color and the icon is a spinner instead of an arrow.
class PendingTxStrip extends ConsumerWidget {
  const PendingTxStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingTxsProvider);
    final pending = async.valueOrNull ?? const <PendingTxItem>[];
    if (pending.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final tx in pending) _PendingTile(tx: tx)],
      ),
    );
  }
}

class _PendingTile extends ConsumerStatefulWidget {
  const _PendingTile({required this.tx});
  final PendingTxItem tx;

  @override
  ConsumerState<_PendingTile> createState() => _PendingTileState();
}

class _PendingTileState extends ConsumerState<_PendingTile> {
  bool _busy = false;

  Future<void> _run(Future<String> Function() op, String label) async {
    setState(() => _busy = true);
    try {
      final newHash = await op();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label · ${_short(newHash)}'),
          duration: const Duration(seconds: 3),
        ),
      );
      ref.invalidate(pendingTxsProvider);
      unawaited(ref.read(historyNotifierProvider.notifier).refresh());
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage(e)), backgroundColor: context.colors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tx = widget.tx;
    final accent = colors.warning;
    const repo = ReplacementGrpcRepository();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Left accent bar ────────────────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: accent.withValues(alpha: 0.7)),
          ),
          // ── Content ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 10, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spinner icon (mirrors _TxIcon size from confirmed tile)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.8, color: accent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _kindLabel(tx.kind),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _PendingBadge(accent: accent),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // value=0 means an ERC-20 transfer / contract call —
                      // the token amount is encoded in the tx data and
                      // unavailable here without decoding. Just show the
                      // recipient + leave the asset details for History
                      // once the tx mines.
                      Text(
                        _isZero(tx.value)
                            ? '→ ${_short(tx.to)}'
                            : '${tx.value} ETH → ${_short(tx.to)}',
                        style: AppTextStyles.monoSmall.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'nonce ${tx.nonce} · tip ${tx.gasTipGwei} gwei · cap ${tx.gasCapGwei} gwei',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (_busy)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.6, color: colors.primary),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionBtn(
                        label: 'Speed up',
                        color: colors.primary,
                        onTap: () => _run(() => repo.speedUp(tx.txHash), 'Speed-up sent'),
                      ),
                      const SizedBox(width: 4),
                      _ActionBtn(
                        label: 'Cancel',
                        color: colors.error,
                        onTap: () => _run(() => repo.cancel(tx.txHash), 'Cancel sent'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _kindLabel(String kind) {
    switch (kind) {
      case 'speed-up':
        return 'Speed-up';
      case 'cancel':
        return 'Cancel';
      case 'swap':
        return 'Swap';
      case 'approve':
        return 'Approve';
      case 'send':
      default:
        return 'Send';
    }
  }

  String _short(String hex) {
    if (hex.length <= 12) return hex;
    return '${hex.substring(0, 6)}…${hex.substring(hex.length - 4)}';
  }

  /// Backend ships PendingTx.value as a human ETH string ("0", "0.001",
  /// "0.00000000"). Treat anything that parses to zero as "no native value".
  bool _isZero(String value) {
    final v = double.tryParse(value);
    return v == null || v == 0;
  }
}

// ── "Pending" badge — sits next to the kind label, mirrors _AssetBadge ─────

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'PENDING',
        style: AppTextStyles.labelMedium.copyWith(
          color: accent,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
