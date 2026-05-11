import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

/// A row inside a [SettingsSection].
///
/// Supply either [value] (displays read-only text) or [trailing]
/// (a custom widget, e.g. a button or badge).
class SettingsRow {
  const SettingsRow({
    required this.label,
    this.subtitle,
    this.value,
    this.trailing,
  }) : assert(
         value != null || trailing != null,
         'Provide either value or trailing',
       );

  final String label;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
}

/// A titled section card containing a list of [SettingsRow]s separated by
/// subtle dividers.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.rows,
    super.key,
    this.titleColor,
  });

  final String title;
  final List<SettingsRow> rows;

  /// Override the section title color (e.g. red for Danger Zone).
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
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

        // Rows card
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                _SettingsRowTile(row: rows[i]),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.border,
                    indent: 20,
                    endIndent: 0,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRowTile extends StatelessWidget {
  const _SettingsRowTile({required this.row});

  final SettingsRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        children: [
          // Label + optional subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                row.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              if (row.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  row.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.textDisabled,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(width: 12),

          // Value or trailing widget
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  row.trailing ??
                  Text(
                    row.value ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
