import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/state/privacy_provider.dart';

/// Renders [value] as plain text — or as a fixed-width mask (`••••••`) when
/// the global [hideBalancesProvider] is enabled.
///
/// Use everywhere a balance, USD value, or other sensitive number is shown.
class MaskableText extends ConsumerWidget {
  const MaskableText(
    this.value, {
    this.style,
    this.maskLength = 6,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String value;
  final TextStyle? style;
  final int maskLength;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hideBalancesProvider);
    final shown = hidden ? '•' * maskLength : value;
    return Text(shown, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
  }
}
