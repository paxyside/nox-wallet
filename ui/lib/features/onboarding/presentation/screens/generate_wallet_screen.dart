import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/onboarding/domain/wallet_repository.dart';
import 'package:nox/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:nox/features/onboarding/presentation/screens/_shared_widgets.dart';

class GenerateWalletScreen extends ConsumerStatefulWidget {
  const GenerateWalletScreen({super.key});

  @override
  ConsumerState<GenerateWalletScreen> createState() => _GenerateWalletScreenState();
}

class _GenerateWalletScreenState extends ConsumerState<GenerateWalletScreen> {
  final _labelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _savedConfirmed = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(generateWalletNotifierProvider.notifier)
        .generateWallet(_labelController.text.trim());
  }

  void _onContinue() {
    invalidateWalletScopedCaches(ref);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(generateWalletNotifierProvider);

    ref.listen(generateWalletNotifierProvider, (_, next) {
      if (next.hasError) {
        showErrorSnackBar(context, next.error.toString());
      }
    });

    final wallet = asyncState.valueOrNull;
    final isLoading = asyncState.isLoading;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: BackButton(
          color: context.colors.textSecondary,
          onPressed: () {
            ref.read(generateWalletNotifierProvider.notifier).reset();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(Routes.onboarding);
            }
          },
        ),
        title: Text(
          'Create new wallet',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: wallet == null ? _buildLabelForm(isLoading) : _buildMnemonicView(wallet),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Name your wallet',
            style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Give this wallet a label so you can identify it later.',
            style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 32),
          OnboardingTextField(
            controller: _labelController,
            label: 'Wallet label',
            hint: 'e.g. Main wallet',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
          ),
          const SizedBox(height: 32),
          OnboardingPrimaryButton(
            label: 'Generate wallet',
            isLoading: isLoading,
            onPressed: isLoading ? null : _generate,
          ),
        ],
      ),
    );
  }

  Widget _buildMnemonicView(GeneratedWallet wallet) {
    final words = wallet.mnemonic.trim().split(RegExp(r'\s+'));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your recovery phrase',
            style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Write down these words in the exact order shown. '
            'Store them safely — they are the only way to recover your wallet.',
            style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 24),
          _WarningBanner(),
          const SizedBox(height: 24),
          _MnemonicGrid(words: words),
          const SizedBox(height: 16),
          _CopyButton(mnemonic: wallet.mnemonic),
          const SizedBox(height: 24),
          _ConfirmCheckbox(
            value: _savedConfirmed,
            onChanged: (v) => setState(() => _savedConfirmed = v ?? false),
          ),
          const SizedBox(height: 24),
          OnboardingPrimaryButton(
            label: 'Continue to wallet',
            isLoading: false,
            onPressed: _savedConfirmed ? _onContinue : null,
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: context.colors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Never share your recovery phrase with anyone. '
              'Anyone with these words can access your funds.',
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _MnemonicGrid extends StatelessWidget {
  const _MnemonicGrid({required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [for (int i = 0; i < words.length; i++) _WordChip(index: i + 1, word: words[i])],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.index, required this.word});

  final int index;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$index.',
            style: AppTextStyles.monoSmall.copyWith(color: context.colors.textDisabled),
          ),
          const SizedBox(width: 6),
          Text(word, style: AppTextStyles.mono.copyWith(color: context.colors.textPrimary)),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.mnemonic});

  final String mnemonic;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.mnemonic));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_rounded,
        size: 16,
        color: context.colors.textSecondary,
      ),
      label: Text(
        _copied ? 'Copied!' : 'Copy to clipboard',
        style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

class _ConfirmCheckbox extends StatelessWidget {
  const _ConfirmCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? context.colors.primary.withValues(alpha: 0.08) : context.colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value ? context.colors.primary : context.colors.border),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: context.colors.primary,
              side: BorderSide(color: context.colors.border),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I have written down my recovery phrase and stored it securely.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
