import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/widgets/right_drawer.dart';
import 'package:nox/features/tokens/domain/watched_token.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:nox/features/tokens/presentation/widgets/token_details_drawer.dart';
import 'package:nox/features/tokens/presentation/widgets/token_list_tile_main_row.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main tile — opens the per-token details drawer when the user clicks the
// kebab in the main row. The previous inline expanded section is gone; all
// metadata + actions live in the drawer now.
// ─────────────────────────────────────────────────────────────────────────────

class TokenListTile extends ConsumerStatefulWidget {
  const TokenListTile({required this.token, super.key});

  final WatchedToken token;

  @override
  ConsumerState<TokenListTile> createState() => _TokenListTileState();
}

class _TokenListTileState extends ConsumerState<TokenListTile> {
  bool _hovered = false;
  TokenTimeframe _tf = TokenTimeframe.d7;

  WatchedToken get t => widget.token;

  List<double> _sparklineFor(TokenTimeframe tf) => switch (tf) {
    TokenTimeframe.d1 =>
      t.sparkline7d.length > 24 ? t.sparkline7d.sublist(t.sparkline7d.length - 24) : t.sparkline7d,
    TokenTimeframe.d7 => t.sparkline7d,
    TokenTimeframe.d30 => t.sparkline30d,
  };

  Future<void> _openDrawer() {
    return showRightDrawer<void>(
      context,
      builder: (_) => TokenDetailsDrawer(token: t),
    );
  }

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
        child: TokenListTileMainRow(
          token: t,
          hovered: _hovered,
          tf: _tf,
          sparkline: _sparklineFor(_tf),
          onOpenDetails: _openDrawer,
          onPin: () => ref.read(tokensNotifierProvider.notifier).togglePin(t.id),
          onTimeframe: (v) => setState(() => _tf = v),
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
