import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

/// A single cell in a [CompactSettingsRow]. Visual structure:
///
///   ┌─────────────────────────────────────────────────────────────┐
///   │  [icon]   LABEL                            [trailing]       │
///   │           subtitle                                          │
///   └─────────────────────────────────────────────────────────────┘
///
/// The leading icon sits in a small primary-tinted square so the eye
/// hits it first and the row reads like a row of cards rather than
/// undifferentiated text. `danger: true` swaps the icon tile to a
/// red tint — used by Danger Zone entries.
class CompactSettingsCell {
  const CompactSettingsCell({
    required this.icon,
    required this.label,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.trailingBelow = false,
    this.danger = false,
    this.iconColor,
  }) : assert(
         subtitle == null || subtitleWidget == null,
         'Provide either subtitle (plain text) or subtitleWidget (custom), not both',
       );

  final IconData icon;
  final String label;
  final String? subtitle;

  /// Override the icon tile's accent colour. Defaults to the theme's
  /// primary (or error when [danger] is true). Use for cells where the
  /// trailing action has a non-default colour (e.g. amber Reveal
  /// button on a "caution-but-not-quite-danger" setting) so the icon
  /// tile reads the same tone as the action.
  final Color? iconColor;

  /// Render a custom widget in the subtitle position instead of plain
  /// text. Useful when the cell's value should stand out — e.g. the
  /// wallet's user-given label, which we render as a styled pill.
  /// Mutually exclusive with [subtitle].
  final Widget? subtitleWidget;

  final Widget? trailing;

  /// When true, [trailing] is rendered below the label/subtitle stack
  /// rather than to the right. Use for wide controls (dropdowns,
  /// badges) that would otherwise squeeze the label to ellipsis in
  /// narrow cells (e.g. one of three Wallet cells, or one of two
  /// Security cells).
  final bool trailingBelow;

  final bool danger;
}

/// Renders a list of [CompactSettingsCell]s in a single Row, wrapped in
/// the same card chrome as the legacy `SettingsSection`. Cells are
/// equal-width with vertical dividers separating them; pass an empty
/// `title` to render as a continuation row of the preceding section.
///
/// Set `danger: true` to tint the card border red — used by the Import
/// new wallet card so the destructive action visually stands apart
/// from everything else on the page.
class CompactSettingsRow extends StatefulWidget {
  const CompactSettingsRow({
    required this.title,
    required this.cells,
    super.key,
    this.titleColor,
    this.danger = false,
  });

  final String title;
  final List<CompactSettingsCell> cells;
  final Color? titleColor;
  final bool danger;

  @override
  State<CompactSettingsRow> createState() => _CompactSettingsRowState();
}

class _CompactSettingsRowState extends State<CompactSettingsRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.danger ? context.colors.error : context.colors.primary;
    final restingBorder = widget.danger
        ? context.colors.error.withValues(alpha: 0.45)
        : context.colors.border;
    final hoverBorder = widget.danger
        ? context.colors.error.withValues(alpha: 0.65)
        : accent.withValues(alpha: 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suppress the title for continuation rows so the second
        // CompactSettingsRow under Security doesn't repeat the header.
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              widget.title.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: widget.titleColor ?? context.colors.textSecondary,
                fontSize: 11.5,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _hovered ? context.colors.surfaceHigh : context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _hovered ? hoverBorder : restingBorder, width: 1),
              boxShadow: [
                if (widget.danger)
                  BoxShadow(
                    color: context.colors.error.withValues(alpha: 0.06),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                // Soft accent inner glow on hover — adds the "living
                // surface" feel without making the card look pressed.
                if (_hovered)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < widget.cells.length; i++) ...[
                    Expanded(child: _CompactCellTile(cell: widget.cells[i])),
                    if (i < widget.cells.length - 1)
                      VerticalDivider(width: 1, thickness: 1, color: context.colors.border),
                  ],
                ],
              ),
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
    // Default icon tile is NEUTRAL — only attention-worthy cells
    // (Reveal: warning, Import: danger) get a coloured accent. Painting
    // every icon primary purple made the whole screen shout for the same
    // amount of attention; neutral tiles let real signals stand out.
    final isAccent = cell.danger || cell.iconColor != null;
    final accent = cell.danger
        ? context.colors.error
        : (cell.iconColor ?? context.colors.textSecondary);
    final iconBg = accent.withValues(alpha: isAccent ? 0.12 : 0.08);
    final iconBorder = accent.withValues(alpha: isAccent ? 0.25 : 0.18);

    final iconTile = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconBorder),
      ),
      alignment: Alignment.center,
      child: Icon(cell.icon, size: 16, color: accent),
    );

    final labelStack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cell.label,
          style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (cell.subtitleWidget != null) ...[
          const SizedBox(height: 6),
          cell.subtitleWidget!,
        ] else if (cell.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            cell.subtitle!,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    // Outer row anchors the icon to the TOP — IntrinsicHeight makes
    // sibling cells in the same Row stretch to match the tallest one,
    // and an icon floating mid-cell looks awkward. Inside the outer
    // row, the label+subtitle and the trailing widget share an inner
    // row that vertically CENTERS them, so the toggle/dropdown/button
    // sits at the middle of the text stack instead of pinned to its
    // top. trailingBelow=true bypasses this and stacks trailing
    // beneath the label vertically.
    final inlineContent = cell.trailing != null && !cell.trailingBelow
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: labelStack),
              const SizedBox(width: 10),
              cell.trailing!,
            ],
          )
        : (cell.trailing != null && cell.trailingBelow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    labelStack,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: cell.trailing),
                  ],
                )
              : labelStack);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconTile,
          const SizedBox(width: 10),
          Expanded(child: inlineContent),
        ],
      ),
    );
  }
}
