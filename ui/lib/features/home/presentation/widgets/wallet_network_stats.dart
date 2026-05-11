import 'package:flutter/material.dart';
import 'package:nox/core/balance/balance_repository.dart';
import 'package:nox/core/theme/app_colors.dart';

double? _parseGwei(String raw) => double.tryParse(raw.split(' ').first);

String _formatGwei(String raw) {
  final v = _parseGwei(raw);
  if (v == null) return raw;
  if (v < 1) return '${v.toStringAsFixed(2)} Gwei';
  if (v < 100) return '${v.toStringAsFixed(1)} Gwei';
  return '${v.toStringAsFixed(0)} Gwei';
}

String _gasCostUsd(String maxFeeGwei, BalanceData balanceData) {
  final gwei = _parseGwei(maxFeeGwei);
  if (gwei == null || gwei == 0) return '';
  final usdStr = balanceData.ethUsdValue.replaceAll(RegExp(r'[^\d.]'), '');
  final usd = double.tryParse(usdStr) ?? 0;
  final eth = double.tryParse(balanceData.ethBalance) ?? 0;
  if (eth == 0 || usd == 0) return '';
  final cost = gwei * 21000 / 1e9 * (usd / eth);
  if (cost < 0.01) return r'<$0.01';
  return '\$${cost.toStringAsFixed(2)}';
}

String _formatBlock(int n) {
  if (n == 0) return '—';
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// Network stats — Gas + Block, bigger
// ─────────────────────────────────────────────────────────────────────────────

class WalletNetworkStats extends StatelessWidget {
  const WalletNetworkStats({
    required this.gasStats,
    required this.balanceData,
    super.key,
  });

  final GasStats gasStats;
  final BalanceData balanceData;

  @override
  Widget build(BuildContext context) {
    final usdCost = _gasCostUsd(gasStats.maxFeeGwei, balanceData);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatChip(
            icon: Icons.local_gas_station_outlined,
            label: usdCost.isNotEmpty ? 'Gas · $usdCost' : 'Gas',
            value: _formatGwei(gasStats.baseFeeGwei),
          ),
          Container(
            width: 1,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: context.colors.border,
          ),
          _StatChip(
            icon: Icons.tag_rounded,
            label: 'Block',
            value: _formatBlock(gasStats.blockNumber),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: context.colors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                fontFamily: 'monospace',
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
