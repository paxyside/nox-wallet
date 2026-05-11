import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';

/// Small icon button that copies [value] to the clipboard. Briefly swaps the
/// copy icon for a checkmark (~1.5s) and shows a confirmation snackbar.
class CopyButton extends StatefulWidget {
  const CopyButton({
    required this.value,
    this.successMessage = 'Copied to clipboard.',
    this.tooltip = 'Copy',
    this.size = 14,
    this.color,
    super.key,
  });

  final String value;
  final String successMessage;
  final String tooltip;
  final double size;
  final Color? color;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _onTap() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    AppSnackBar.info(context, widget.successMessage);
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.color ?? (_copied ? context.colors.success : context.colors.textDisabled);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => unawaited(_onTap()),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              _copied ? Icons.check_rounded : Icons.copy_outlined,
              key: ValueKey(_copied),
              size: widget.size,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
