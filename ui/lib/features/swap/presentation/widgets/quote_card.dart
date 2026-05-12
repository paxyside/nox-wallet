import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/swap/domain/swap_quote.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    required this.quote,
    required this.assetIn,
    required this.assetOut,
    required this.amountIn,
    super.key,
  });

  final SwapQuote quote;
  final SwapAsset? assetIn;
  final SwapAsset? assetOut;
  final String amountIn;

  // ── Formatters ─────────────────────────────────────────────────────────────

  String get _rate {
    final inAmt = double.tryParse(amountIn);
    final outAmt = double.tryParse(quote.amountOut);
    if (inAmt == null || outAmt == null || inAmt == 0) return '—';
    final rate = outAmt / inAmt;
    return _fmtNum(rate);
  }

  static String _fmtNum(double v) {
    if (v >= 1e6) return v.toStringAsExponential(3);
    if (v >= 1000) return _withCommas(v.toStringAsFixed(2));
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
  }

  static String _withCommas(String s) {
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  String get _gasLabel {
    // Prefer showing Gwei (consistent with send screen and dashboard).
    final gweiStr = _fmtGwei(quote.maxFeeGwei);
    final usd = quote.gasCostUsd;
    if (gweiStr != null) {
      return usd != null && usd.isNotEmpty ? '$gweiStr · $usd' : gweiStr;
    }
    // Fallback: gas units if Gwei unavailable.
    final units = int.tryParse(quote.gasEstimate);
    final unitsStr = units == null
        ? '${quote.gasEstimate} gas'
        : units >= 1000000
        ? '${(units / 1e6).toStringAsFixed(2)}M gas'
        : units >= 1000
        ? '${(units / 1000).toStringAsFixed(0)}k gas'
        : '$units gas';
    return usd != null && usd.isNotEmpty ? '$unitsStr · $usd' : unitsStr;
  }

  static String? _fmtGwei(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null) return null;
    if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
    if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
    return '${v.toStringAsFixed(0)} Gwei';
  }

  @override
  Widget build(BuildContext context) {
    final inSym = assetIn?.symbol ?? '?';
    final outSym = assetOut?.symbol ?? '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Rate header ────────────────────────────────────────────────
          Row(
            children: [
              Text(
                '1 $inSym =',
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$_rate $outSym',
                style: AppTextStyles.mono.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: context.colors.border),
          const SizedBox(height: 12),

          // ── Gas estimate ───────────────────────────────────────────────
          _DetailRow(
            label: 'Gas estimate',
            tooltip: 'Estimated network fee for this transaction.',
            value: _gasLabel,
          ),

          const SizedBox(height: 10),

          // ── Max slippage ───────────────────────────────────────────────
          _DetailRow(
            label: 'Max slippage',
            tooltip: 'Your swap reverts if the output falls below this tolerance.',
            value: '0.5%',
            valueColor: context.colors.warning,
          ),

          const SizedBox(height: 10),

          // ── Route ──────────────────────────────────────────────────────
          Row(
            children: [
              const _LabelWithTooltip(
                label: 'Route',
                tooltip: 'The path your swap takes through liquidity pools.',
              ),
              const Spacer(),
              // In token
              TokenIcon(symbol: assetIn?.symbol ?? '', logoUrl: assetIn?.logoUrl, size: 18),
              const SizedBox(width: 5),
              Text(
                inSym,
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 13, color: context.colors.textDisabled),
              const SizedBox(width: 8),
              // Out token
              TokenIcon(symbol: assetOut?.symbol ?? '', logoUrl: assetOut?.logoUrl, size: 18),
              const SizedBox(width: 5),
              Text(
                outSym,
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row: label + tooltip + value
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.tooltip,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String tooltip;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LabelWithTooltip(label: label, tooltip: tooltip),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.mono.copyWith(
            color: valueColor ?? context.colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Label + ⓘ tooltip
// ---------------------------------------------------------------------------

class _LabelWithTooltip extends StatelessWidget {
  const _LabelWithTooltip({required this.label, required this.tooltip});

  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
        const SizedBox(width: 5),
        Tooltip(
          message: tooltip,
          child: Icon(Icons.info_outline_rounded, size: 13, color: context.colors.textDisabled),
        ),
      ],
    );
  }
}
