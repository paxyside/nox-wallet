import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/send/data/simulation_repository.dart';
import 'package:nox/features/send/domain/send_repository.dart';

/// Confirmation modal shown before a Send is dispatched.
///
/// Returns `true` from `Navigator.pop` when the user taps **Confirm Send**,
/// `false` when they tap **Cancel** (or dismiss the dialog).
///
/// Layout reads top-to-bottom: hero amount → recipient card → fee card →
/// simulation banner → actions. The boring label/value table from before
/// felt like a tax return — this version mirrors what mobile wallets do.
class SendConfirmDialog extends StatefulWidget {
  const SendConfirmDialog({
    required this.recipient,
    required this.amount,
    required this.symbol,
    this.tokenAddress = '',
    this.gasEstimate,
    this.effectiveMaxFeeGwei,
    this.amountUsd,
    super.key,
  });

  final String recipient;
  final String amount;
  final String symbol;

  /// Empty for native ETH, contract address for ERC-20.
  final String tokenAddress;
  final GasEstimate? gasEstimate;

  /// Tier-adjusted max-fee per gas (gwei). When null, falls back to
  /// `gasEstimate.maxFee` for the readings.
  final double? effectiveMaxFeeGwei;
  final String? amountUsd;

  @override
  State<SendConfirmDialog> createState() => _SendConfirmDialogState();
}

class _SendConfirmDialogState extends State<SendConfirmDialog> {
  static const _simRepo = SimulationGrpcRepository();

  Future<SimulationResult>? _simulation;

  @override
  void initState() {
    super.initState();
    _simulation = _simRepo.simulate(
      to: widget.recipient,
      amount: widget.amount,
      tokenAddress: widget.tokenAddress,
    );
  }

  // ── Derived gas readings (tier-aware) ──────────────────────────────────────

  double get _maxFeeGwei {
    final eff = widget.effectiveMaxFeeGwei;
    if (eff != null && eff > 0) return eff;
    return double.tryParse(widget.gasEstimate?.maxFee ?? '') ?? 0;
  }

  String? get _gasGwei {
    final ge = widget.gasEstimate;
    if (ge == null) return null;
    final v = _maxFeeGwei;
    if (v == 0) return '0 Gwei';
    if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
    if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
    return '${v.toStringAsFixed(0)} Gwei';
  }

  String? get _gasUsd {
    final ge = widget.gasEstimate;
    if (ge == null || ge.ethPriceUsd == null) return null;
    final usd = ge.estimatedGas * _maxFeeGwei * 1e-9 * ge.ethPriceUsd!;
    if (usd <= 0) return null;
    if (usd < 0.01) return r'<$0.01';
    return '\$${usd.toStringAsFixed(2)}';
  }

  /// "Total" only meaningful for native ETH (amount + gas). For tokens, gas
  /// is paid in ETH separately so total isn't a single-currency sum.
  String? get _totalEth {
    if (widget.symbol.toUpperCase() != 'ETH') return null;
    final amt = double.tryParse(widget.amount) ?? 0;
    final ge = widget.gasEstimate;
    if (amt == 0 || ge == null) return null;
    final gasEth = ge.estimatedGas * _maxFeeGwei * 1e-9;
    if (gasEth <= 0) return null;
    return _trim((amt + gasEth).toStringAsFixed(8));
  }

  static String _trim(String s) {
    if (!s.contains('.')) return s;
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _short(String hex) {
    if (hex.length <= 16) return hex;
    return '${hex.substring(0, 8)}…${hex.substring(hex.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Center(
                child: Text(
                  'Confirm Transaction',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Hero amount ────────────────────────────────────────────
              Center(
                child: Text(
                  '${widget.amount} ${widget.symbol}',
                  style: AppTextStyles.h1.copyWith(
                    color: colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.amountUsd != null && widget.amountUsd!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '≈ ${widget.amountUsd}',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ── Recipient card ─────────────────────────────────────────
              _MetaCard(
                label: 'TO',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _short(widget.recipient),
                        style: AppTextStyles.mono.copyWith(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CopyIcon(value: widget.recipient),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Network fee card ───────────────────────────────────────
              if (_gasGwei != null)
                _MetaCard(
                  label: 'NETWORK FEE',
                  child: Row(
                    children: [
                      Icon(Icons.local_gas_station_rounded, size: 16, color: colors.warning),
                      const SizedBox(width: 8),
                      Text(
                        _gasGwei!,
                        style: AppTextStyles.mono.copyWith(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_gasUsd != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· ${_gasUsd!}',
                          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                        ),
                      ],
                      const Spacer(),
                      if (_totalEth != null)
                        Text(
                          'Total $_totalEth ETH',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textDisabled,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // ── Simulation banner ──────────────────────────────────────
              FutureBuilder<SimulationResult>(
                future: _simulation,
                builder: (_, snapshot) => _SimulationBanner(snapshot: snapshot),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Confirm Send',
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

// ── Bordered card with a small all-caps label and free-form body ────────────

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
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
          child,
        ],
      ),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  const _CopyIcon({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copy address',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          unawaited(Clipboard.setData(ClipboardData(text: value)));
          AppSnackBar.info(context, 'Address copied.');
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.copy_rounded, size: 14, color: context.colors.textSecondary),
        ),
      ),
    );
  }
}

// ── Simulation banner ──────────────────────────────────────────────────────

class _SimulationBanner extends StatelessWidget {
  const _SimulationBanner({required this.snapshot});

  final AsyncSnapshot<SimulationResult> snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState != ConnectionState.done) {
      return _shell(
        context,
        color: context.colors.textDisabled,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Simulating transaction…',
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (snapshot.hasError || snapshot.data == null) {
      return _shell(
        context,
        color: context.colors.textDisabled,
        child: Text(
          'Simulation unavailable.',
          style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
      );
    }

    final r = snapshot.data!;
    if (r.willRevert) {
      return _shell(
        context,
        color: context.colors.error,
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 14, color: context.colors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                r.revertReason.isEmpty ? 'Will revert on chain.' : 'Will revert: ${r.revertReason}',
                style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
              ),
            ),
          ],
        ),
      );
    }

    return _shell(
      context,
      color: context.colors.success,
      child: Row(
        children: [
          Icon(Icons.verified_rounded, size: 14, color: context.colors.success),
          const SizedBox(width: 8),
          Text(
            'Will succeed',
            style: AppTextStyles.labelMedium.copyWith(
              color: context.colors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shell(BuildContext context, {required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}
