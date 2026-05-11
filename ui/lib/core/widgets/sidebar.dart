import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/theme/theme_provider.dart';
import 'package:nox/core/widgets/about_dialog.dart';
import 'package:nox/core/widgets/app_dialog.dart';

// ---------------------------------------------------------------------------
// Sidebar — static, fixed width
// ---------------------------------------------------------------------------

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  static const double _width = 220;
  static const double _headerHeight = 64;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return SizedBox(
      width: _width,
      child: ColoredBox(
        color: context.colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logo header ──────────────────────────────────────────────
            SizedBox(
              height: _headerHeight,
              child: _SidebarHeader(),
            ),

            const SizedBox(height: 8),

            // ── Main nav ─────────────────────────────────────────────────
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              route: Routes.home,
              selected: location == Routes.home,
            ),
            _NavItem(
              icon: Icons.arrow_upward_rounded,
              label: 'Send',
              route: Routes.send,
              selected: location == Routes.send,
            ),
            _NavItem(
              icon: Icons.swap_horiz_rounded,
              label: 'Swap',
              route: Routes.swap,
              selected: location == Routes.swap,
            ),
            _NavItem(
              icon: Icons.token_outlined,
              label: 'Tokens',
              route: Routes.tokens,
              selected: location == Routes.tokens,
            ),
            _NavItem(
              icon: Icons.contacts_outlined,
              label: 'Contacts',
              route: Routes.contacts,
              selected: location == Routes.contacts,
            ),
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'History',
              route: Routes.history,
              selected: location == Routes.history,
            ),
            _NavItem(
              icon: Icons.shield_outlined,
              label: 'Approvals',
              route: Routes.approvals,
              selected: location == Routes.approvals,
            ),

            const Spacer(),

            // ── Settings ─────────────────────────────────────────────────
            _NavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              route: Routes.settings,
              selected: location == Routes.settings,
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(height: 1, color: context.colors.border),
            ),
            const SizedBox(height: 8),

            // ── Bottom icon row ──────────────────────────────────────────
            // Network status (chain name + gwei + block) was previously
            // here as `_NetworkStatusBlock`, but the Dashboard already
            // surfaces the same data top-right with a pulsing dot. Keeping
            // it in the sidebar duplicated the info on every screen for no
            // additional signal — removed to declutter.
            const _BottomIconRow(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar header — logo + "Nox Wallet"
// ---------------------------------------------------------------------------

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/nox_logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Nox Wallet',
            style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav item
// ---------------------------------------------------------------------------

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool selected;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final fg = selected
        ? context.colors.primaryLight
        : _hovered
        ? context.colors.textPrimary
        : context.colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selected
                    ? [
                        context.colors.primary.withValues(alpha: 0.22),
                        context.colors.primary.withValues(alpha: 0.08),
                      ]
                    : _hovered
                    ? [
                        context.colors.surfaceHigh,
                        context.colors.surfaceHigh,
                      ]
                    : [
                        Colors.transparent,
                        Colors.transparent,
                      ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? context.colors.primary.withValues(alpha: 0.35)
                    : _hovered
                    ? context.colors.border
                    : Colors.transparent,
              ),
            ),
            child: Stack(
              children: [
                if (selected)
                  Positioned(
                    left: 0,
                    top: 4,
                    bottom: 4,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: 22, color: fg),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: fg,
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom icon row — lock, help, theme toggle
// ---------------------------------------------------------------------------

class _BottomIconRow extends ConsumerWidget {
  const _BottomIconRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeNotifierProvider);
    final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = mode == ThemeMode.dark || (mode == ThemeMode.system && systemDark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _IconBtn(
            icon: Icons.lock_outline_rounded,
            tooltip: 'Lock wallet',
            onTap: () => ref.read(isUnlockedProvider.notifier).lock(),
          ),
          _IconBtn(
            icon: Icons.help_outline_rounded,
            tooltip: 'About',
            onTap: () => showAppDialog<void>(
              context: context,
              builder: (_) => const AppAboutDialog(),
            ),
          ),
          _IconBtn(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onTap: () => ref.read(themeModeNotifierProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hovered ? context.colors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 19,
              color: _hovered ? context.colors.textSecondary : context.colors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}
