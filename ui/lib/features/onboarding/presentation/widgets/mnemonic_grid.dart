import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/features/onboarding/data/bip39_wordlist.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Word grid
// ─────────────────────────────────────────────────────────────────────────────

class MnemonicGrid extends StatelessWidget {
  const MnemonicGrid({
    required this.count,
    required this.controllers,
    required this.focusNodes,
    required this.showError,
    super.key,
  });
  final int count;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool showError;

  static const _cols = 3;

  /// Distributes [words] into controllers starting at [startIndex], then
  /// moves focus to the next empty field after the last filled one.
  void _distributeWords(int startIndex, List<String> words) {
    for (var i = 0; i < words.length; i++) {
      final targetIndex = startIndex + i;
      if (targetIndex >= count) break;
      controllers[targetIndex].text = words[i];
    }
    // Advance focus to the first empty field after the last filled word,
    // or to the field right after the last pasted word, whichever comes first.
    final lastFilled = startIndex + words.length - 1;
    final nextIndex = lastFilled + 1;
    if (nextIndex < count) {
      focusNodes[nextIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = (count / _cols).ceil();
    return Column(
      children: [
        for (int row = 0; row < rows; row++) ...[
          if (row > 0) const SizedBox(height: 6),
          Row(
            children: [
              for (int col = 0; col < _cols; col++) ...[
                if (col > 0) const SizedBox(width: 6),
                Expanded(
                  child: _WordCell(
                    index: row * _cols + col,
                    controller: controllers[row * _cols + col],
                    focusNode: focusNodes[row * _cols + col],
                    nextFocus: (row * _cols + col + 1) < count
                        ? focusNodes[row * _cols + col + 1]
                        : null,
                    showError: showError,
                    onAdvance: () {
                      final next = row * _cols + col + 1;
                      if (next < count) focusNodes[next].requestFocus();
                    },
                    onWordsDistribute: _distributeWords,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Word cell  (EditableText — zero platform chrome)
// ─────────────────────────────────────────────────────────────────────────────

class _WordCell extends StatefulWidget {
  const _WordCell({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.showError,
    this.nextFocus,
    this.onAdvance,
    this.onWordsDistribute,
  });
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final bool showError;

  /// Called when the user types a space and focus should move to the next field.
  final VoidCallback? onAdvance;

  /// Called when the user pastes multiple words; the grid distributes them
  /// starting at `startIndex` (which is this cell's index + 1 for extras).
  final void Function(int startIndex, List<String> words)? onWordsDistribute;

  @override
  State<_WordCell> createState() => _WordCellState();
}

class _WordCellState extends State<_WordCell> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);

  void _onTextChanged() {
    final text = widget.controller.text;

    if (text.contains(' ')) {
      final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      if (words.length > 1) {
        // Multi-word paste: put first word in this field, distribute rest onward.
        widget.controller.value = TextEditingValue(
          text: words[0],
          selection: TextSelection.collapsed(offset: words[0].length),
        );
        widget.onWordsDistribute?.call(widget.index + 1, words.sublist(1));
      } else {
        // Single word followed by a trailing space → trim and advance.
        final trimmed = text.trim();
        widget.controller.value = TextEditingValue(
          text: trimmed,
          selection: TextSelection.collapsed(offset: trimmed.length),
        );
        widget.onAdvance?.call();
      }
      return;
    }

    // No space — check if it's a complete BIP39 word → auto-advance.
    final trimmed = text.trim();
    if (trimmed.isNotEmpty && kBip39Words.contains(trimmed)) {
      widget.onAdvance?.call();
      return;
    }
    setState(() {});
  }

  bool get _empty => widget.controller.text.trim().isEmpty;
  bool get _isError => widget.showError && _empty;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isError
        ? context.colors.error.withValues(alpha: 0.65)
        : _focused
        ? context.colors.primary
        : context.colors.border;

    final bgColor = _isError
        ? context.colors.error.withValues(alpha: 0.04)
        : _focused
        ? context.colors.primary.withValues(alpha: 0.06)
        : context.colors.surfaceHigh;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
            final text = widget.controller.text.trim();
            if (text.isNotEmpty) {
              widget.controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
              widget.onAdvance?.call();
            }
          }
        },
        child: GestureDetector(
          onTap: () => widget.focusNode.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: _focused ? 1.5 : 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '${widget.index + 1}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: context.colors.textDisabled,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: EditableText(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: widget.nextFocus != null
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onSubmitted: (_) => widget.nextFocus?.requestFocus(),
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: context.colors.textPrimary,
                      height: 1.2,
                    ),
                    cursorColor: context.colors.primary,
                    backgroundCursorColor: Colors.transparent,
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
