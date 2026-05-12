part of '../mini_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Balance card — USD + ETH + address + network chip + dialog with refresh
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.homeAsync});

  final AsyncValue<HomeState> homeAsync;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: col.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.border),
      ),
      child: homeAsync.when(
        loading: () => const _BalanceSkeleton(),
        error: (err, _) => SizedBox(
          height: 80,
          child: Center(
            child: Text(
              'Failed to load balance',
              style: AppTextStyles.bodySmall.copyWith(color: col.error),
            ),
          ),
        ),
        data: (state) => _BalanceContent(
          ethBalance: state.balanceData.ethBalance,
          ethUsd: state.balanceData.ethUsdValue,
          ethLogoUrl: state.balanceData.ethLogoUrl,
          address: state.walletInfo.address,
        ),
      ),
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return SizedBox(
      height: 80,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: col.textDisabled),
        ),
      ),
    );
  }
}

class _BalanceContent extends StatelessWidget {
  const _BalanceContent({
    required this.ethBalance,
    required this.ethUsd,
    required this.ethLogoUrl,
    required this.address,
  });

  final String ethBalance;
  final String ethUsd;
  final String ethLogoUrl;
  final String address;

  String get _shortAddr => address.length > 12
      ? '${address.substring(0, 6)}…${address.substring(address.length - 4)}'
      : address;

  String get _ethFormatted => formatAmount(ethBalance, maxFrac: 4);

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: USD + ETH + address.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ethUsd.isNotEmpty)
                MaskableText(
                  ethUsd,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: col.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.05,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  TokenIcon(symbol: 'ETH', logoUrl: ethLogoUrl, size: 16),
                  const SizedBox(width: 6),
                  MaskableText(
                    '$_ethFormatted ETH',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: col.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _AddressChip(address: address, shortAddr: _shortAddr),
            ],
          ),
        ),
        // Right: network chip — tap opens info dialog with refresh.
        const _NetworkChip(),
      ],
    );
  }
}

class _AddressChip extends StatefulWidget {
  const _AddressChip({required this.address, required this.shortAddr});
  final String address;
  final String shortAddr;

  @override
  State<_AddressChip> createState() => _AddressChipState();
}

class _AddressChipState extends State<_AddressChip> {
  bool _copied = false;

  void _copy() {
    unawaited(Clipboard.setData(ClipboardData(text: widget.address)));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _copy,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.shortAddr,
              style: AppTextStyles.mono.copyWith(color: col.textDisabled, fontSize: 11),
            ),
            const SizedBox(width: 4),
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_outlined,
              size: 11,
              color: _copied ? col.success : col.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkChip extends ConsumerStatefulWidget {
  const _NetworkChip();

  @override
  ConsumerState<_NetworkChip> createState() => _NetworkChipState();
}

class _NetworkChipState extends ConsumerState<_NetworkChip> {
  bool _hovered = false;

  void _showNetworkInfo() {
    final homeAsync = ref.read(homeDataProvider);
    final refreshedAt = ref.read(homeDataRefreshedAtProvider);
    final state = homeAsync.valueOrNull;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => _NetworkInfoDialog(gasStats: state?.gasStats, refreshedAt: refreshedAt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _showNetworkInfo,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? col.surfaceHigh : col.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: col.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: col.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ethereum',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: col.textPrimary,
                      fontSize: 11.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Mainnet',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: col.textDisabled,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 14, color: col.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkInfoDialog extends ConsumerWidget {
  const _NetworkInfoDialog({required this.gasStats, required this.refreshedAt});

  final GasStats? gasStats;
  final DateTime? refreshedAt;

  String _formatGwei(String s) {
    final v = double.tryParse(s);
    if (v == null) return '$s Gwei';
    return '${v.toStringAsFixed(v >= 10 ? 1 : 2)} Gwei';
  }

  String _formatBlock(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final gas = gasStats;
    return Dialog(
      backgroundColor: col.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: col.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ethereum · Mainnet',
                    style: AppTextStyles.h3.copyWith(color: col.textPrimary, fontSize: 15),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 16, color: col.textSecondary),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (gas == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Network data not available yet.',
                    style: AppTextStyles.bodySmall.copyWith(color: col.textSecondary),
                  ),
                )
              else ...[
                _NetworkInfoRow(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Gas (base fee)',
                  value: _formatGwei(gas.baseFeeGwei),
                ),
                const SizedBox(height: 10),
                _NetworkInfoRow(
                  icon: Icons.layers_rounded,
                  label: 'Block',
                  value: '#${_formatBlock(gas.blockNumber)}',
                ),
              ],
              const SizedBox(height: 14),
              Divider(height: 1, color: col.border),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.update_rounded, size: 12, color: col.textDisabled),
                  const SizedBox(width: 6),
                  Text(
                    refreshedAt == null ? 'Never updated' : 'Updated ${timeAgo(refreshedAt!)}',
                    style: AppTextStyles.bodySmall.copyWith(color: col.textDisabled, fontSize: 11),
                  ),
                  const Spacer(),
                  _DialogRefreshButton(onTap: () => ref.invalidate(homeDataProvider)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkInfoRow extends StatelessWidget {
  const _NetworkInfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Row(
      children: [
        Icon(icon, size: 14, color: col.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: col.textSecondary, fontSize: 12.5),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: col.textPrimary,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _DialogRefreshButton extends StatefulWidget {
  const _DialogRefreshButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DialogRefreshButton> createState() => _DialogRefreshButtonState();
}

class _DialogRefreshButtonState extends State<_DialogRefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool _hovered = false;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _onTap() {
    unawaited(_spin.forward(from: 0));
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered ? col.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hovered ? col.border : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spin,
                child: Icon(
                  Icons.refresh_rounded,
                  size: 12,
                  color: _hovered ? col.textPrimary : col.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Refresh',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _hovered ? col.textPrimary : col.textSecondary,
                  fontSize: 11,
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
