import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expanded details row
// ─────────────────────────────────────────────────────────────────────────────

class TokenListTileExpandedRow extends StatelessWidget {
  const TokenListTileExpandedRow({
    required this.token,
    required this.onExplorer,
    required this.onHide,
    required this.onRemove,
    super.key,
  });

  final WatchedToken token;
  final VoidCallback onExplorer;
  final VoidCallback onHide;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border.withValues(alpha: 0.5))),
      ),
      padding: const EdgeInsets.fromLTRB(40, 10, 16, 12),
      child: Row(
        children: [
          _DetailChip(
            label: 'Contract',
            value:
                '${token.address.substring(0, 10)}…${token.address.substring(token.address.length - 8)}',
            onTap: () {
              unawaited(Clipboard.setData(ClipboardData(text: token.address)));
              AppSnackBar.info(context, 'Contract address copied.');
            },
            icon: Icons.copy_outlined,
          ),
          const SizedBox(width: 10),
          _DetailChip(label: 'Decimals', value: '${token.decimals}'),
          const SizedBox(width: 10),
          _DetailChip(
            label: 'Etherscan',
            value: 'View →',
            onTap: onExplorer,
            icon: Icons.open_in_new_rounded,
          ),
          const Spacer(),
          // ── Hide is the soft option (suppresses from default views but keeps
          //    in DB so the auto-seed dedup map still recognises it, and so
          //    the user can unhide it later). Remove is the hard permanent
          //    delete. Both live in the expanded row to keep them away from
          //    accidental row-tap. The chip flips between "Hide" / "Show"
          //    based on the row's current state so the same expanded row
          //    works in both Visible and Hidden filter views.
          _DetailChip(
            label: '',
            value: token.isHidden ? 'Show' : 'Hide',
            onTap: onHide,
            icon: token.isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          const SizedBox(width: 6),
          _DetailChip(
            label: '',
            value: 'Remove',
            onTap: onRemove,
            icon: Icons.delete_outline_rounded,
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatefulWidget {
  const _DetailChip({
    required this.label,
    required this.value,
    this.onTap,
    this.icon,
    this.danger = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool danger;

  @override
  State<_DetailChip> createState() => _DetailChipState();
}

class _DetailChipState extends State<_DetailChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.danger ? context.colors.error : context.colors.textPrimary;
    final bgColor = widget.danger
        ? context.colors.error.withValues(alpha: _hovered ? 0.15 : 0.08)
        : (_hovered && widget.onTap != null
              ? context.colors.surfaceHigh
              : context.colors.surfaceHigh);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.danger
                  ? context.colors.error.withValues(alpha: 0.3)
                  : context.colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.label.isNotEmpty) ...[
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 11, color: baseColor),
                const SizedBox(width: 4),
              ],
              Text(
                widget.value,
                style: TextStyle(fontSize: 11, color: baseColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
