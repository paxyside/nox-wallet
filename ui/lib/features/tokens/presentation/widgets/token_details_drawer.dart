import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/right_drawer.dart';
import 'package:nox/core/widgets/token_icon.dart';
import 'package:nox/features/approvals/domain/approval.dart';
import 'package:nox/features/approvals/presentation/providers/approvals_provider.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Per-token detail drawer — replaces the inline expanded row that used
/// to live on the Tokens screen. Visual language mirrors the Settings
/// screen: each section is a framed card, each row is an icon-tile cell
/// with a label, subtitle, and trailing widget. The drawer is sized to
/// fit common content without scrolling; the approvals list — which can
/// vary from 0 to many — is hidden behind a dropdown so its content
/// doesn't push the rest of the drawer off-screen.
class TokenDetailsDrawer extends ConsumerWidget {
  const TokenDetailsDrawer({required this.token, super.key});

  final WatchedToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RightDrawerScaffold(
      scrollable: false,
      header: _DrawerHeader(token: token),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Details ───────────────────────────────────────────────
          _Section(
            title: 'Details',
            children: [
              _CellTile(
                icon: Icons.description_outlined,
                label: 'Contract',
                subtitle: _shortAddress(token.address),
                trailing: _IconTrailing(
                  icon: Icons.copy_rounded,
                  tooltip: 'Copy address',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: token.address));
                    if (context.mounted) {
                      AppSnackBar.info(context, 'Contract address copied.');
                    }
                  },
                ),
              ),
              _CellTile(
                icon: Icons.tag_rounded,
                label: 'Decimals',
                subtitle: '${token.decimals}',
              ),
              _CellTile(
                icon: Icons.public_rounded,
                label: 'Explorer',
                subtitle: 'Etherscan',
                trailing: _IconTrailing(
                  icon: Icons.open_in_new_rounded,
                  tooltip: 'Open Etherscan',
                  onTap: () => launchUrl(
                    Uri.parse('https://etherscan.io/token/${token.address}'),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Approvals (collapsed dropdown so it doesn't grow drawer) ─
          _ApprovalsCell(token: token),

          const SizedBox(height: 10),

          // ── Actions ───────────────────────────────────────────────
          _Section(
            title: 'Actions',
            children: [
              _CellTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Send',
                subtitle: 'Transfer to any address',
                iconColor: context.colors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('${Routes.send}?token=${token.address}');
                },
              ),
              _CellTile(
                icon: Icons.swap_horiz_rounded,
                label: 'Swap',
                subtitle: 'Exchange via Uniswap V3',
                iconColor: context.colors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('${Routes.swap}?tokenIn=${token.address}');
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Manage ────────────────────────────────────────────────
          _Section(
            title: 'Manage',
            children: [
              _CellTile(
                icon: token.isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                label: token.isHidden ? 'Show on dashboard' : 'Hide from dashboard',
                subtitle: 'Token stays tracked either way',
                onTap: () async {
                  await ref
                      .read(tokensNotifierProvider.notifier)
                      .hide(token.id, hidden: !token.isHidden);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              _CellTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove from wallet',
                subtitle: 'Stop tracking this token',
                danger: true,
                onTap: () => _confirmRemove(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ctx.colors.border),
        ),
        title: Text(
          'Remove ${token.symbol.isEmpty ? 'token' : token.symbol}?',
          style: AppTextStyles.h3.copyWith(color: ctx.colors.textPrimary),
        ),
        content: Text(
          'Stop tracking this token. You can re-add it later by pasting the contract address.',
          style: AppTextStyles.bodyMedium.copyWith(color: ctx.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: ctx.colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ctx.colors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: AppTextStyles.labelLarge.copyWith(color: ctx.colors.textPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(tokensNotifierProvider.notifier).remove(token.id);
        if (context.mounted) Navigator.of(context).pop();
      } on Object catch (_) {
        if (context.mounted) {
          AppSnackBar.error(context, 'Failed to remove token.');
        }
      }
    }
  }
}

String _shortAddress(String address) => address.length > 14
    ? '${address.substring(0, 8)}…${address.substring(address.length - 6)}'
    : address;

// ────────────────────────────────────────────────────────────────────────────
// Header — icon + symbol/name + close
// ────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.token});
  final WatchedToken token;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      child: Row(
        children: [
          TokenIcon(symbol: token.symbol, logoUrl: token.logoUrl, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.symbol,
                  style: AppTextStyles.h3.copyWith(color: col.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (token.name.isNotEmpty)
                  Text(
                    token.name,
                    style: AppTextStyles.bodySmall.copyWith(color: col.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: col.textSecondary, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 16,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Section — uppercase title + framed card matching Settings chrome
// ────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: col.textSecondary,
              fontSize: 11.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: col.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: col.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) Divider(height: 1, color: col.border, indent: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _CellTile — shared row visual matching the Settings CompactSettingsCell:
// 32×32 icon tile (neutral by default; accent when iconColor set or danger),
// label + subtitle stack, optional trailing widget. Hoverable only when
// `onTap` is supplied (so read-only rows like Decimals don't suggest action).
// ────────────────────────────────────────────────────────────────────────────

class _CellTile extends StatefulWidget {
  const _CellTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool danger;

  @override
  State<_CellTile> createState() => _CellTileState();
}

class _CellTileState extends State<_CellTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final tappable = widget.onTap != null;
    final isAccent = widget.danger || widget.iconColor != null;
    final accent = widget.danger ? col.error : (widget.iconColor ?? col.textSecondary);
    final iconBg = accent.withValues(alpha: isAccent ? (_hovered ? 0.18 : 0.12) : 0.08);
    final iconBorder = accent.withValues(alpha: isAccent ? (_hovered ? 0.4 : 0.25) : 0.18);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconBorder),
            ),
            alignment: Alignment.center,
            child: Icon(widget.icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium.copyWith(color: col.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: col.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            widget.trailing!,
          ] else if (tappable) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: col.textDisabled),
          ],
        ],
      ),
    );

    if (!tappable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          color: _hovered ? accent.withValues(alpha: 0.08) : Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _IconTrailing — small ghost icon button for trailing slots (copy/open).
// Matches the visual weight of the ThemedDropdown trigger so trailing
// widgets in different cells read as one family.
// ────────────────────────────────────────────────────────────────────────────

class _IconTrailing extends StatefulWidget {
  const _IconTrailing({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_IconTrailing> createState() => _IconTrailingState();
}

class _IconTrailingState extends State<_IconTrailing> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
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
            duration: const Duration(milliseconds: 120),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _hovered ? col.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: _hovered ? col.primary.withValues(alpha: 0.45) : col.border,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 14,
              color: _hovered ? col.textPrimary : col.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _ApprovalsCell — single Settings-style cell with a dropdown trailing.
// Trigger pill says "X approvals" (or "None" when empty); clicking opens
// an overlay panel listing each approval with a Revoke button. The cell
// width and drawer height never change, regardless of approval count.
// ────────────────────────────────────────────────────────────────────────────

class _ApprovalsCell extends ConsumerWidget {
  const _ApprovalsCell({required this.token});
  final WatchedToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = context.colors;
    final asyncApprovals = ref.watch(approvalsNotifierProvider);

    return _Section(
      title: 'Approvals',
      children: [
        asyncApprovals.when(
          loading: () => _CellTile(
            icon: Icons.shield_outlined,
            label: 'Active approvals',
            subtitle: 'Checking on-chain…',
            trailing: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: col.textDisabled),
            ),
          ),
          error: (_, _) => _CellTile(
            icon: Icons.shield_outlined,
            label: 'Active approvals',
            subtitle: "Couldn't load approvals",
            iconColor: col.error,
          ),
          data: (all) {
            final matching = all
                .where((a) => a.tokenAddress.toLowerCase() == token.address.toLowerCase())
                .toList();

            final hasUnlimited = matching.any(
              (a) => a.amountHuman.toLowerCase().contains('unlimited'),
            );
            final accent = matching.isEmpty
                ? null
                : (hasUnlimited ? col.error : const Color(0xFFF59E0B));

            return _CellTile(
              icon: Icons.shield_outlined,
              label: 'Active approvals',
              subtitle: matching.isEmpty
                  ? 'No spenders authorised'
                  : '${matching.length} spender${matching.length == 1 ? '' : 's'} authorised',
              iconColor: accent,
              trailing: _ApprovalsDropdown(
                approvals: matching,
                onRevoke: (a) => _revoke(context, ref, a),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref, TokenApproval approval) async {
    try {
      final hash = await ref
          .read(approvalsNotifierProvider.notifier)
          .revoke(approval.tokenAddress, approval.spender);
      if (context.mounted) {
        AppSnackBar.success(context, 'Revoke broadcast — tx $hash');
      }
    } on Object catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Revoke failed: $e');
      }
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _ApprovalsDropdown — ThemedDropdown-style trigger + overlay panel.
// Empty state: disabled pill reading "None". Populated: pill reads
// "N active", clicking opens the list of approvals with Revoke buttons.
// ────────────────────────────────────────────────────────────────────────────

class _ApprovalsDropdown extends StatefulWidget {
  const _ApprovalsDropdown({required this.approvals, required this.onRevoke});

  final List<TokenApproval> approvals;
  final ValueChanged<TokenApproval> onRevoke;

  @override
  State<_ApprovalsDropdown> createState() => _ApprovalsDropdownState();
}

class _ApprovalsDropdownState extends State<_ApprovalsDropdown> {
  bool _hovered = false;
  bool _open = false;
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  void _toggle() {
    if (widget.approvals.isEmpty) return;
    if (_open) {
      _close();
    } else {
      _show();
    }
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _open = false);
  }

  void _show() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final triggerSize = box.size;
    const panelWidth = 300.0;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            // Anchor the panel's top-right corner just below the trigger's
            // bottom-right corner, so the panel hangs into the drawer
            // body instead of clipping past the right edge.
            offset: Offset(triggerSize.width - panelWidth, triggerSize.height + 6),
            child: _ApprovalsPanel(
              width: panelWidth,
              approvals: widget.approvals,
              onRevoke: (a) {
                _close();
                widget.onRevoke(a);
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final count = widget.approvals.length;
    final empty = count == 0;
    final active = !empty && (_hovered || _open);

    final label = empty ? 'None' : '$count active';

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: empty ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _toggle,
          // Chrome lifted verbatim from ThemedDropdown so the trigger
          // reads as part of the same family — same padding, radius,
          // chevron, label weight. The dropdown logic is local because
          // panel content (Revoke buttons, badges, addresses) doesn't
          // fit ThemedDropdown's plain-label item model.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active ? col.surfaceHigh : col.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? col.primary.withValues(alpha: 0.5) : col.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: empty ? col.textDisabled : col.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 160),
                  turns: _open ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: empty ? col.textDisabled : col.textSecondary,
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

class _ApprovalsPanel extends StatefulWidget {
  const _ApprovalsPanel({
    required this.width,
    required this.approvals,
    required this.onRevoke,
  });

  final double width;
  final List<TokenApproval> approvals;
  final ValueChanged<TokenApproval> onRevoke;

  @override
  State<_ApprovalsPanel> createState() => _ApprovalsPanelState();
}

class _ApprovalsPanelState extends State<_ApprovalsPanel> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      opacity: _shown ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topRight,
        scale: _shown ? 1 : 0.94,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: col.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: col.border),
              boxShadow: [
                // Match ThemedDropdown._Panel shadow exactly.
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.approvals.length; i++) ...[
                    _PanelApprovalRow(
                      approval: widget.approvals[i],
                      onRevoke: () => widget.onRevoke(widget.approvals[i]),
                    ),
                    if (i < widget.approvals.length - 1)
                      Divider(height: 1, color: col.border, indent: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelApprovalRow extends StatelessWidget {
  const _PanelApprovalRow({required this.approval, required this.onRevoke});

  final TokenApproval approval;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final isUnlimited = approval.amountHuman.toLowerCase().contains('unlimited');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        approval.spenderLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: col.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isUnlimited ? col.error : col.textSecondary).withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: (isUnlimited ? col.error : col.textSecondary).withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Text(
                        approval.amountHuman,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isUnlimited ? col.error : col.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _shortAddress(approval.spender),
                  style: AppTextStyles.mono.copyWith(color: col.textDisabled, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRevoke,
            style: TextButton.styleFrom(
              foregroundColor: col.error,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: col.error.withValues(alpha: 0.45)),
              ),
            ),
            child: Text(
              'Revoke',
              style: AppTextStyles.labelMedium.copyWith(
                color: col.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
