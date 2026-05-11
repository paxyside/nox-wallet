import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

/// Displays a token logo loaded from the Trust Wallet Assets CDN.
/// Falls back to a coloured letter avatar when the image is unavailable.
///
/// Usage:
///   TokenIcon(symbol: 'USDC', address: '0xA0b8...')
///   TokenIcon(symbol: 'ETH')   // native ETH — no address needed
class TokenIcon extends StatelessWidget {
  const TokenIcon({
    required this.symbol,
    super.key,
    this.address,
    this.size = 36,
  });

  final String symbol;

  /// ERC-20 contract address (checksummed). Null / empty for native ETH.
  final String? address;

  final double size;

  // ── Trust Wallet Assets CDN ───────────────────────────────────────────────

  static const _twBase =
      'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum';

  String? get _logoUrl {
    final sym = symbol.toUpperCase();

    if (sym == 'ETH') {
      return '$_twBase/info/logo.png';
    }

    final addr = address;
    if (addr != null && addr.isNotEmpty && addr != '0x0000000000000000000000000000000000000000') {
      return '$_twBase/assets/$addr/logo.png';
    }

    return null;
  }

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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final url = _logoUrl;
    final letter = symbol.isNotEmpty ? symbol.toUpperCase()[0] : '?';
    final fontSize = size * 0.38;

    final Widget fallback = Container(
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
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: _color,
          height: 1,
        ),
      ),
    );

    if (url == null) return fallback;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Show a subtle placeholder while loading.
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
            );
          },
          errorBuilder: (context, error, stack) => fallback,
        ),
      ),
    );
  }
}
