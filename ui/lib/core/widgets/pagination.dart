import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

/// Compact pagination bar — page numbers with ellipsis, prev/next buttons.
///
/// [current]  — 0-indexed current page.
/// [total]    — total number of pages loaded so far.
/// [hasMore]  — server has more items beyond [total] pages.
/// [loading]  — a load-more request is in flight.
/// [onPage]   — called with the new 0-indexed page when user taps a page.
class AppPagination extends StatelessWidget {
  const AppPagination({
    required this.current,
    required this.total,
    required this.onPage,
    super.key,
    this.hasMore = false,
    this.loading = false,
  });

  final int current;
  final int total;
  final bool hasMore;
  final bool loading;
  final ValueChanged<int> onPage;

  List<int?> _buildPages() {
    if (total <= 7) return List.generate(total, (i) => i);

    final set = <int>{}
      ..add(0)
      ..add(total - 1);
    for (var i = current - 2; i <= current + 2; i++) {
      if (i >= 0 && i < total) set.add(i);
    }

    final sorted = set.toList()..sort();
    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      result.add(sorted[i]);
      if (i < sorted.length - 1 && sorted[i + 1] - sorted[i] > 1) {
        result.add(null);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavBtn(
            icon: Icons.chevron_left_rounded,
            enabled: current > 0,
            onTap: () => onPage(current - 1),
          ),
          const SizedBox(width: 4),

          ...pages.map(
            (p) => p == null
                ? const _Ellipsis()
                : _PageNum(page: p + 1, selected: p == current, onTap: () => onPage(p)),
          ),

          if (hasMore)
            loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: context.colors.textDisabled,
                      ),
                    ),
                  )
                : const _Ellipsis(),

          const SizedBox(width: 4),
          _NavBtn(
            icon: Icons.chevron_right_rounded,
            enabled: current < total - 1,
            onTap: () => onPage(current + 1),
          ),
        ],
      ),
    );
  }
}

// ── Page number button ────────────────────────────────────────────────────────

class _PageNum extends StatefulWidget {
  const _PageNum({required this.page, required this.selected, required this.onTap});

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PageNum> createState() => _PageNumState();
}

class _PageNumState extends State<_PageNum> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.selected
                ? context.colors.primary
                : _hovered
                ? context.colors.surfaceHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: widget.selected
                  ? context.colors.primary
                  : _hovered
                  ? context.colors.border
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              '${widget.page}',
              style: AppTextStyles.labelMedium.copyWith(
                color: widget.selected ? context.colors.textPrimary : context.colors.textSecondary,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Prev / Next button ────────────────────────────────────────────────────────

class _NavBtn extends StatefulWidget {
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<_NavBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: (_hovered && widget.enabled) ? context.colors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: (_hovered && widget.enabled) ? context.colors.border : Colors.transparent,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.enabled ? context.colors.textSecondary : context.colors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ellipsis ──────────────────────────────────────────────────────────────────

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 34,
      child: Center(
        child: Text(
          '…',
          style: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
        ),
      ),
    );
  }
}
