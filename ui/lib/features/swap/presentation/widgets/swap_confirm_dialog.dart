import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

/// Pre-flight preview shown before a Swap is dispatched.
///
/// Returns `true` from `Navigator.pop` for **Confirm Swap**, `false` for
/// **Cancel** / dismiss. The screen below executes the swap on `true`.
///
/// Mirrors `SendConfirmDialog`'s style: small header → hero rate →
/// from/to token cards → fee + slippage + route metadata → actions.
class SwapConfirmDialog extends StatelessWidget {
  const SwapConfirmDialog({
    required this.quote,
    required this.assetIn,
    required this.assetOut,
    required this.amountIn,
    required this.effectiveMaxFeeGwei,
    super.key,
  });

  final SwapQuote quote;
  final SwapAsset? assetIn;
  final SwapAsset? assetOut;
  final String amountIn;
  final double effectiveMaxFeeGwei;

  // ── Derived strings ────────────────────────────────────────────────────────

  String get _rateLabel {
    final inAmt = double.tryParse(amountIn);
    final outAmt = double.tryParse(quote.amountOut);
    if (inAmt == null || outAmt == null || inAmt == 0) return '—';
    final rate = outAmt / inAmt;
    return _fmtRate(rate);
  }

  static String _fmtRate(double v) {
    if (v >= 1e6) return v.toStringAsExponential(3);
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
  }

  String get _gasGwei {
    final v = effectiveMaxFeeGwei;
    if (v == 0) return '0 Gwei';
    if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
    if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
    return '${v.toStringAsFixed(0)} Gwei';
  }

  /// Rescale the quote's gasCostUsd to the active tier's cap so the USD
  /// shown in the dialog matches the headline gwei. Same trick as in the
  /// in-screen gas card.
  String? get _gasUsd {
    final raw = quote.gasCostUsd;
    if (raw == null || raw.isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp('[^0-9.]'), '');
    final v = double.tryParse(cleaned);
    final baseMax = double.tryParse(quote.maxFeeGwei ?? '');
    if (v == null || baseMax == null || baseMax == 0 || effectiveMaxFeeGwei == 0) {
      return raw;
    }
    final scaled = v * (effectiveMaxFeeGwei / baseMax);
    if (scaled <= 0) return null;
    if (scaled < 0.01) return r'<$0.01';
    return '\$${scaled.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inSym = assetIn?.symbol ?? '?';
    final outSym = assetOut?.symbol ?? '?';

    return Dialog(
      backgroundColor: colors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Small header ───────────────────────────────────────────
              Center(
                child: Text(
                  'Confirm Swap',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── From / To token cards ──────────────────────────────────
              _SideCard(
                label: 'YOU PAY',
                amount: amountIn,
                symbol: inSym,
                tokenAddress: assetIn?.tokenAddress,
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.18),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SideCard(
                label: 'YOU RECEIVE',
                amount: quote.amountOut,
                symbol: outSym,
                tokenAddress: assetOut?.tokenAddress,
                accent: colors.success,
              ),

              const SizedBox(height: 18),

              // ── Rate ───────────────────────────────────────────────────
              _MetaRow(
                label: 'Rate',
                tooltip: 'Effective price you receive at the moment of quote.',
                value: '1 $inSym = $_rateLabel $outSym',
                mono: true,
              ),
              const SizedBox(height: 8),
              _MetaRow(
                label: 'Network fee',
                tooltip: 'Maximum gas fee for the selected speed tier.',
                value: _gasUsd != null ? '$_gasGwei · $_gasUsd' : _gasGwei,
                mono: true,
              ),
              const SizedBox(height: 8),
              _MetaRow(
                label: 'Max slippage',
                tooltip: 'Your swap reverts on chain if the output falls below this tolerance.',
                value: '0.5%',
                valueColor: colors.warning,
              ),
              const SizedBox(height: 8),
              _RouteRow(
                inSymbol: inSym,
                outSymbol: outSym,
                inAddress: assetIn?.tokenAddress,
                outAddress: assetOut?.tokenAddress,
              ),

              const SizedBox(height: 22),

              // ── Actions ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm Swap',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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
}

// ── From / To side card ─────────────────────────────────────────────────────

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.label,
    required this.amount,
    required this.symbol,
    this.tokenAddress,
    this.accent,
  });

  final String label;
  final String amount;
  final String symbol;
  final String? tokenAddress;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: colors.textDisabled,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: AppTextStyles.h2.copyWith(
                    color: accent ?? colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              TokenIcon(symbol: symbol, address: tokenAddress, size: 22),
              const SizedBox(width: 6),
              Text(
                symbol,
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Meta row (label + tooltip + value) ──────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.tooltip,
    required this.value,
    this.valueColor,
    this.mono = false,
  });

  final String label;
  final String tooltip;
  final String value;
  final Color? valueColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = (mono ? AppTextStyles.mono : AppTextStyles.labelMedium).copyWith(
      color: valueColor ?? colors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: tooltip,
          child: Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: colors.textDisabled,
          ),
        ),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.inSymbol,
    required this.outSymbol,
    this.inAddress,
    this.outAddress,
  });

  final String inSymbol;
  final String outSymbol;
  final String? inAddress;
  final String? outAddress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          'Route',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Path your swap takes through liquidity pools.',
          child: Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: colors.textDisabled,
          ),
        ),
        const Spacer(),
        TokenIcon(symbol: inSymbol, address: inAddress, size: 18),
        const SizedBox(width: 5),
        Text(
          inSymbol,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_rounded,
          size: 13,
          color: colors.textDisabled,
        ),
        const SizedBox(width: 8),
        TokenIcon(symbol: outSymbol, address: outAddress, size: 18),
        const SizedBox(width: 5),
        Text(
          outSymbol,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
