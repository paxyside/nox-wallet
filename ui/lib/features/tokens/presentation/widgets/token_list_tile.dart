import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:nox/features/tokens/presentation/widgets/token_list_tile_expanded_row.dart';
import 'package:nox/features/tokens/presentation/widgets/token_list_tile_main_row.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main tile
// ─────────────────────────────────────────────────────────────────────────────

class TokenListTile extends ConsumerStatefulWidget {
  const TokenListTile({
    required this.token,
    required this.onHide,
    required this.onRemove,
    super.key,
  });

  final WatchedToken token;
  final VoidCallback onHide;
  final VoidCallback onRemove;

  @override
  ConsumerState<TokenListTile> createState() => _TokenListTileState();
}

class _TokenListTileState extends ConsumerState<TokenListTile> {
  bool _hovered = false;
  bool _expanded = false;
  TokenTimeframe _tf = TokenTimeframe.d7;

  WatchedToken get t => widget.token;

  void _openExplorer() => launchUrl(Uri.parse('https://etherscan.io/token/${t.address}'));

  List<double> _sparklineFor(TokenTimeframe tf) => switch (tf) {
    TokenTimeframe.d1 =>
      t.sparkline7d.length > 24 ? t.sparkline7d.sublist(t.sparkline7d.length - 24) : t.sparkline7d,
    TokenTimeframe.d7 => t.sparkline7d,
    TokenTimeframe.d30 => t.sparkline30d,
  };

  @override
  Widget build(BuildContext context) {
    // Hidden tokens render muted so the user immediately sees they're
    // not part of the normal portfolio — restored to full opacity once
    // the row is hovered, so the user can read details before un-hiding.
    final muted = t.isHidden && !_hovered;
    final tile = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered ? context.colors.surfaceHigh : context.colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered
                ? context.colors.border
                : (t.isPinned
                      ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                      : Colors.transparent),
          ),
        ),
        child: Column(
          children: [
            TokenListTileMainRow(
              token: t,
              hovered: _hovered,
              expanded: _expanded,
              tf: _tf,
              sparkline: _sparklineFor(_tf),
              onToggleExpand: () => setState(() => _expanded = !_expanded),
              onPin: () => ref.read(tokensNotifierProvider.notifier).togglePin(t.id),
              onTimeframe: (v) => setState(() => _tf = v),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              firstChild: const SizedBox.shrink(),
              secondChild: TokenListTileExpandedRow(
                token: t,
                onExplorer: _openExplorer,
                onHide: widget.onHide,
                onRemove: widget.onRemove,
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: muted ? 0.5 : 1.0,
      child: tile,
    );
  }
}
