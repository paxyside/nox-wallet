import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:nox/features/onboarding/presentation/screens/_shared_widgets.dart';
import 'package:nox/features/onboarding/presentation/widgets/clean_field.dart';
import 'package:nox/features/onboarding/presentation/widgets/mnemonic_atoms.dart';
import 'package:nox/features/onboarding/presentation/widgets/mnemonic_grid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ImportMnemonicScreen extends ConsumerStatefulWidget {
  const ImportMnemonicScreen({super.key});

  @override
  ConsumerState<ImportMnemonicScreen> createState() => _ImportMnemonicScreenState();
}

class _ImportMnemonicScreenState extends ConsumerState<ImportMnemonicScreen> {
  final _pageController = PageController();
  int _page = 0;

  // ── Phrase state ────────────────────────────────────────────────────────────
  int _wordCount = 12;
  final List<TextEditingController> _wc = List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _fn = List.generate(24, (_) => FocusNode());
  bool _phraseSubmitted = false;

  // ── Details state ───────────────────────────────────────────────────────────
  final _labelController = TextEditingController();
  final _labelFocus = FocusNode();
  final _derivController = TextEditingController();
  final _derivFocus = FocusNode();
  bool _showDeriv = false;
  bool _detailsSubmitted = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _wc) {
      c.dispose();
    }
    for (final f in _fn) {
      f.dispose();
    }
    _labelController.dispose();
    _labelFocus.dispose();
    _derivController.dispose();
    _derivFocus.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _slideTo(int index) {
    setState(() => _page = index);
    unawaited(
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _onBack() {
    if (_page == 1) {
      _slideTo(0);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(Routes.onboarding);
    }
  }

  // ── Phrase page actions ─────────────────────────────────────────────────────

  void _switchWordCount(int count) {
    setState(() {
      _wordCount = count;
      _phraseSubmitted = false;
      for (var i = count; i < 24; i++) {
        _wc[i].clear();
      }
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text?.trim() ?? '';
    if (raw.isEmpty) return;
    final words = raw.split(RegExp(r'\s+'));
    if (words.length != 12 && words.length != 24) {
      if (mounted) {
        showErrorSnackBar(context, 'Expected 12 or 24 words, got ${words.length}');
      }
      return;
    }
    setState(() {
      _wordCount = words.length;
      for (var i = 0; i < words.length; i++) {
        _wc[i].text = words[i];
      }
      _phraseSubmitted = false;
    });
    _toDetails();
  }

  void _clear() {
    setState(() {
      for (final c in _wc) {
        c.clear();
      }
      _phraseSubmitted = false;
    });
  }

  bool get _wordsComplete => _wc.take(_wordCount).every((c) => c.text.trim().isNotEmpty);

  void _onContinue() {
    if (!_wordsComplete) {
      setState(() => _phraseSubmitted = true);
      return;
    }
    _toDetails();
  }

  void _toDetails() {
    _slideTo(1);
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _labelFocus.requestFocus();
    });
  }

  // ── Details page actions ────────────────────────────────────────────────────

  String get _mnemonic => _wc.take(_wordCount).map((c) => c.text.trim()).join(' ');

  Future<void> _import() async {
    if (_labelController.text.trim().isEmpty) {
      setState(() => _detailsSubmitted = true);
      return;
    }
    final ok = await ref
        .read(importMnemonicNotifierProvider.notifier)
        .importMnemonic(
          _mnemonic,
          _labelController.text.trim(),
          derivationPath: _derivController.text.trim(),
        );
    if (ok && mounted) {
      invalidateWalletScopedCaches(ref);
      context.go(Routes.home);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(importMnemonicNotifierProvider);

    ref.listen(importMnemonicNotifierProvider, (_, next) {
      if (next.hasError) showErrorSnackBar(context, next.error.toString());
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: BackButton(color: context.colors.textSecondary, onPressed: _onBack),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_page == 1 ? 0.15 : -0.15, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            _page == 0 ? 'Recovery phrase' : 'Name your wallet',
            key: ValueKey(_page),
            style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _PhrasePage(
                wordCount: _wordCount,
                onWordCountChanged: _switchWordCount,
                controllers: _wc,
                focusNodes: _fn,
                showError: _phraseSubmitted && !_wordsComplete,
                onPaste: _paste,
                onClear: _clear,
                onContinue: _onContinue,
              ),
              _DetailsPage(
                labelController: _labelController,
                labelFocus: _labelFocus,
                derivController: _derivController,
                derivFocus: _derivFocus,
                showDeriv: _showDeriv,
                onToggleDeriv: () => setState(() => _showDeriv = !_showDeriv),
                labelError: _detailsSubmitted && _labelController.text.trim().isEmpty,
                isLoading: asyncState.isLoading,
                onImport: _import,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Phrase
// ─────────────────────────────────────────────────────────────────────────────

class _PhrasePage extends StatelessWidget {
  const _PhrasePage({
    required this.wordCount,
    required this.onWordCountChanged,
    required this.controllers,
    required this.focusNodes,
    required this.showError,
    required this.onPaste,
    required this.onClear,
    required this.onContinue,
  });

  final int wordCount;
  final ValueChanged<int> onWordCountChanged;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool showError;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your phrase',
                      style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type or paste each word in the correct order.',
                      style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              WordCountToggle(value: wordCount, onChanged: onWordCountChanged),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showError)
                Text(
                  'Fill in all words',
                  style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PasteButton(onPressed: onPaste),
                  const SizedBox(width: 16),
                  ClearButton(onPressed: onClear),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          MnemonicGrid(
            count: wordCount,
            controllers: controllers,
            focusNodes: focusNodes,
            showError: showError,
          ),
          const SizedBox(height: 32),
          OnboardingPrimaryButton(label: 'Continue', isLoading: false, onPressed: onContinue),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Details
// ─────────────────────────────────────────────────────────────────────────────

class _DetailsPage extends StatelessWidget {
  const _DetailsPage({
    required this.labelController,
    required this.labelFocus,
    required this.derivController,
    required this.derivFocus,
    required this.showDeriv,
    required this.onToggleDeriv,
    required this.labelError,
    required this.isLoading,
    required this.onImport,
  });

  final TextEditingController labelController;
  final FocusNode labelFocus;
  final TextEditingController derivController;
  final FocusNode derivFocus;
  final bool showDeriv;
  final VoidCallback onToggleDeriv;
  final bool labelError;
  final bool isLoading;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Name your wallet',
            style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a name so you can identify this wallet later.',
            style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 32),
          CleanField(
            controller: labelController,
            focusNode: labelFocus,
            hint: 'e.g. Main wallet',
            hasError: labelError,
            errorText: 'Name is required',
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onToggleDeriv,
            child: Row(
              children: [
                Icon(
                  showDeriv ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: context.colors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Custom derivation path',
                  style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          if (showDeriv) ...[
            const SizedBox(height: 12),
            CleanField(
              controller: derivController,
              focusNode: derivFocus,
              hint: "m/44'/60'/0'/0/0",
              mono: true,
            ),
          ],
          const SizedBox(height: 40),
          OnboardingPrimaryButton(
            label: 'Import wallet',
            isLoading: isLoading,
            onPressed: isLoading ? null : onImport,
          ),
        ],
      ),
    );
  }
}
