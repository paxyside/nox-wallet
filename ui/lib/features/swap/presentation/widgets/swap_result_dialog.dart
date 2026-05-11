import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';

/// Modal shown after a Swap completes — success or failure. Mirrors the
/// Send-side `SendResultDialog` so both flows feel consistent.
///
/// Returns `true` from `Navigator.pop` for "Swap Again", `false` / null
/// for "Close". Caller calls `notifier.reset()` either way.
class SwapResultDialog extends StatelessWidget {
  const SwapResultDialog({
    required this.success,
    required this.txHash,
    required this.amountIn,
    required this.symbolIn,
    required this.amountOut,
    required this.symbolOut,
    this.errorMessage,
    super.key,
  });

  final bool success;
  final String txHash;
  final String amountIn;
  final String symbolIn;
  final String amountOut;
  final String symbolOut;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = success ? colors.success : colors.error;

    return Dialog(
      backgroundColor: colors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _GlowIcon(
                  icon: success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                success ? 'Swap Completed' : 'Swap Failed',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                success
                    ? 'Your swap has been broadcast to the network.'
                    : (errorMessage ?? 'Something went wrong. Please retry.'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),

              if (success && amountIn.isNotEmpty && amountOut.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$amountIn $symbolIn',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$amountOut $symbolOut',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (txHash.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'TRANSACTION HASH',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textDisabled,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _truncateTxHash(txHash),
                          style: AppTextStyles.mono.copyWith(
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tooltip(
                        message: 'Copy hash',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            unawaited(
                              Clipboard.setData(ClipboardData(text: txHash)),
                            );
                            AppSnackBar.info(
                              context,
                              'Transaction hash copied.',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _EtherscanButton(txHash: txHash),
              ],

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Swap Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _truncateTxHash(String hash) {
    if (hash.length <= 22) return hash;
    return '${hash.substring(0, 12)}…${hash.substring(hash.length - 10)}';
  }
}

class _GlowIcon extends StatefulWidget {
  const _GlowIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  State<_GlowIcon> createState() => _GlowIconState();
}

class _GlowIconState extends State<_GlowIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    unawaited(_ctrl.repeat(reverse: true));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final glow = 0.25 + 0.25 * _ctrl.value;
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glow),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(widget.icon, size: 40, color: widget.color),
        );
      },
    );
  }
}

class _EtherscanButton extends StatelessWidget {
  const _EtherscanButton({required this.txHash});
  final String txHash;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openEtherscan(txHash),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: colors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'View on Etherscan',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.primaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEtherscan(String hash) async {
    final url = 'https://etherscan.io/tx/$hash';
    try {
      await Process.run('open', [url]);
    } on Object catch (_) {
      // ignore — best-effort
    }
  }
}
