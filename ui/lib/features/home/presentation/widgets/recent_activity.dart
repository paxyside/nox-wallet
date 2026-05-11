import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/maskable_text.dart';
import 'package:nox/features/history/domain/transaction.dart';
import 'package:nox/features/home/presentation/providers/recent_activity_provider.dart';

final _dateFmt = DateFormat('MMM d, HH:mm');

String _truncate(String hash) {
  if (hash.length <= 12) return hash;
  return '${hash.substring(0, 6)}…${hash.substring(hash.length - 4)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widget — self-contained, watches its own provider
// ─────────────────────────────────────────────────────────────────────────────

class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentActivityProvider);

    return async.when(
      loading: () => _SectionShell(
        items: const [],
        loadingChild: _LoadingRows(),
      ),
      error: (e, s) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _SectionShell(items: items);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shell with title + "View all" link
// ─────────────────────────────────────────────────────────────────────────────

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.items,
    this.loadingChild,
  });

  final List<Transaction> items;
  final Widget? loadingChild;

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (loadingChild != null) {
      body = loadingChild!;
    } else {
      body = Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _ActivityRow(tx: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.h3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.history),
              child: Text(
                'View all →',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.surface,
                  context.colors.surfaceHigh,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: body,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single activity row
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityRow extends StatefulWidget {
  const _ActivityRow({required this.tx});

  final Transaction tx;

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _hovered = false;

  void _openEtherscan() => Process.run('open', ['https://etherscan.io/tx/${widget.tx.txHash}']);

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final incoming = tx.isIncoming;
    final color = incoming ? context.colors.success : context.colors.error;
    final icon = incoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final label = incoming ? 'Received' : 'Sent';
    final valueText = '${incoming ? '+' : '-'}${tx.value}';
    final asset = (tx.asset.isEmpty ? 'ETH' : tx.asset).toUpperCase();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _openEtherscan,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: _hovered ? context.colors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // Direction badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 12),

              // Direction + address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceHigh,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Text(
                            asset,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incoming ? 'From ${_truncate(tx.from)}' : 'To ${_truncate(tx.to)}',
                      style: AppTextStyles.monoSmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Value + time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MaskableText(
                    valueText,
                    style: AppTextStyles.labelMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateFmt.format(tx.blockTime.toLocal()),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new_rounded,
                size: 11,
                color: context.colors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton rows
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingRows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              _Skel(width: 36, height: 36, radius: 18),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Skel(width: 80, height: 12, radius: 4),
                    SizedBox(height: 5),
                    _Skel(width: 140, height: 10, radius: 4),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Skel(width: 60, height: 12, radius: 4),
                  SizedBox(height: 5),
                  _Skel(width: 80, height: 10, radius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Skel extends StatelessWidget {
  const _Skel({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
