import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:nox/features/onboarding/presentation/screens/_shared_widgets.dart';

class ImportKeystoreScreen extends ConsumerStatefulWidget {
  const ImportKeystoreScreen({super.key});

  @override
  ConsumerState<ImportKeystoreScreen> createState() => _ImportKeystoreScreenState();
}

class _ImportKeystoreScreenState extends ConsumerState<ImportKeystoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jsonController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _labelController = TextEditingController();
  bool _obscurePassphrase = true;

  @override
  void dispose() {
    _jsonController.dispose();
    _passphraseController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (!_formKey.currentState!.validate()) return;

    final jsonBytes = utf8.encode(_jsonController.text.trim());

    final success = await ref
        .read(importKeystoreNotifierProvider.notifier)
        .importKeystore(jsonBytes, _passphraseController.text, _labelController.text.trim());
    if (success && mounted) {
      invalidateWalletScopedCaches(ref);
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(importKeystoreNotifierProvider);
    final isLoading = asyncState.isLoading;

    ref.listen(importKeystoreNotifierProvider, (_, next) {
      if (next.hasError) {
        showErrorSnackBar(context, next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: BackButton(color: context.colors.textSecondary, onPressed: () => context.pop()),
        title: Text(
          'Import keystore',
          style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter keystore JSON',
                    style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste the contents of your keystore file and enter its passphrase.',
                    style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  OnboardingTextField(
                    controller: _jsonController,
                    label: 'Keystore JSON',
                    hint: '{"version":3,"id":"...","crypto":{...}}',
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Keystore JSON is required';
                      }
                      try {
                        jsonDecode(v.trim());
                      } on Object catch (_) {
                        return 'Invalid JSON format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PassphraseField(
                    controller: _passphraseController,
                    obscure: _obscurePassphrase,
                    onToggle: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                  ),
                  const SizedBox(height: 16),
                  OnboardingTextField(
                    controller: _labelController,
                    label: 'Wallet label',
                    hint: 'e.g. Imported wallet',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
                  ),
                  const SizedBox(height: 32),
                  OnboardingPrimaryButton(
                    label: 'Import wallet',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _import,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassphraseField extends StatelessWidget {
  const _PassphraseField({required this.controller, required this.obscure, required this.onToggle});

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
      validator: (v) => (v == null || v.isEmpty) ? 'Passphrase is required' : null,
      decoration: InputDecoration(
        labelText: 'Passphrase',
        hintText: 'Keystore passphrase',
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        filled: false,
        fillColor: context.colors.surface,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: context.colors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
