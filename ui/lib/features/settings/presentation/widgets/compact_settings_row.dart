import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

/// A single cell in a [CompactSettingsRow]. Renders as:
///
///   ┌───────────────────────────┐
///   │  LABEL                    │
///   │  Subtitle (optional)      │
///   │  value / trailing         │
///   └───────────────────────────┘
///
/// Designed for the new horizontally-packed Settings sections where
/// stacking everything vertically used to scroll past the fold. Each
/// cell takes equal width in its row (`Expanded` from the parent).
class CompactSettingsCell {
  const CompactSettingsCell({
    required this.label,
    this.subtitle,
    this.value,
    this.trailing,
  }) : assert(value != null || trailing != null, 'Provide either value or trailing');

  final String label;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
}

/// Renders a list of [CompactSettingsCell]s in a single Row, wrapped in
/// the same card chrome as `SettingsSection`. Cells are equal-width;
/// dividers separate them.
///
/// Use this when the section has 2–4 short settings that read fine
/// side-by-side. For one tall setting, the regular `SettingsSection`
/// row layout still wins.
class CompactSettingsRow extends StatelessWidget {
  const CompactSettingsRow({required this.title, required this.cells, super.key, this.titleColor});

  final String title;
  final List<CompactSettingsCell> cells;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Empty title = a continuation row (e.g. the second row of a
        // logically-grouped section like Security's Reveal + Export
        // below Auto-lock + Hide balances). Suppress the title padding
        // so the two rows visually read as part of the same group.
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: titleColor ?? context.colors.textDisabled,
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cells.length; i++) ...[
                  Expanded(child: _CompactCellTile(cell: cells[i])),
                  if (i < cells.length - 1)
                    VerticalDivider(width: 1, thickness: 1, color: context.colors.border),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactCellTile extends StatelessWidget {
  const _CompactCellTile({required this.cell});

  final CompactSettingsCell cell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label + optional subtitle (top half)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cell.label,
                style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
              ),
              if (cell.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  cell.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Value or trailing widget (bottom half, right-aligned)
          Align(
            alignment: Alignment.centerRight,
            child:
                cell.trailing ??
                Text(
                  cell.value ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
          ),
        ],
      ),
    );
  }
}
