import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

/// Token logo renderer.
///
/// The backend stamps a `logoUrl` onto every token in the gRPC
/// response (sourced from the embedded Uniswap Default Token List for
/// ERC-20s and from the network config for the chain's native asset).
/// This widget renders that URL via `Image.network` with a circular
/// crop and falls back to a deterministic letter avatar when:
///   - the URL is null or empty (token not in the verified list);
///   - the network image fails to load (offline, 404, IPFS gateway flake).
///
/// Callers should NOT construct URLs themselves — pass `logoUrl` from
/// the backend response. The only exception is the menubar / wallet
/// header showing the chain's native asset before any RPC has
/// returned; those pass `logoUrl: null` and accept the letter avatar
/// for a few hundred milliseconds until the first GetBalances reply
/// fills it in.
class TokenIcon extends StatelessWidget {
  const TokenIcon({
    required this.symbol,
    super.key,
    this.logoUrl,
    this.size = 36,
    this.showUnverifiedBadge = false,
  });

  /// Display symbol — used both for the letter avatar fallback and
  /// the deterministic colour pick.
  final String symbol;

  /// Logo URL from the backend (`token.logo_url` /
  /// `GetBalances.eth_logo_url`). Null or empty → letter avatar.
  final String? logoUrl;

  /// Rendered diameter in logical pixels.
  final double size;

  /// When true AND `logoUrl` is empty, overlays a small yellow `!`
  /// corner badge — signals to the user that the contract isn't in
  /// the embedded Uniswap Default Token List. Off by default because
  /// long-tail tokens are normal in passive lists; turn it on at
  /// money-on-the-line call sites (swap / send confirm dialogs).
  final bool showUnverifiedBadge;

  // ── Deterministic fallback colour from symbol ─────────────────────────────

  static const _palette = [
    Color(0xFF6C5CE7),
    Color(0xFF00C896),
    Color(0xFFFFB547),
    Color(0xFFFF4F6A),
    Color(0xFF0984E3),
    Color(0xFFE17055),
    Color(0xFF74B9FF),
    Color(0xFFA29BFE),
  ];

  Color get _color {
    if (symbol.isEmpty) return _palette[0];
    return _palette[symbol.toUpperCase().codeUnitAt(0) % _palette.length];
  }

  /// IPFS URLs in the Uniswap list come as `ipfs://Qm…`; Flutter's
  /// Image.network needs an HTTPS gateway. Pass everything else
  /// through unchanged.
  String? _resolveURL(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('ipfs://')) {
      return 'https://ipfs.io/ipfs/${raw.substring(7)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isNotEmpty ? symbol.toUpperCase()[0] : '?';
    final fontSize = size * 0.38;
    final url = _resolveURL(logoUrl);
    final hasLogo = url != null;

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: _color, height: 1),
      ),
    );

    final icon = hasLogo
        ? SizedBox(
            width: size,
            height: size,
            child: ClipOval(child: _image(context, url, fallback)),
          )
        : fallback;

    // No badge requested or token is verified (has a logo) — just the icon.
    if (!showUnverifiedBadge || hasLogo) return icon;

    // Overlay a small yellow "!" corner badge sized as ~35% of the icon
    // diameter. Min 10px so it stays legible at the smallest call sites
    // (16-18px swap rows).
    final badgeSize = (size * 0.35).clamp(10.0, 18.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.surface, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: badgeSize * 0.7,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(BuildContext context, String url, Widget fallback) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle),
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
