import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox/core/router/router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:nox/features/onboarding/presentation/screens/_shared_widgets.dart';

class ImportPrivateKeyScreen extends ConsumerStatefulWidget {
  const ImportPrivateKeyScreen({super.key});

  @override
  ConsumerState<ImportPrivateKeyScreen> createState() => _ImportPrivateKeyScreenState();
}

class _ImportPrivateKeyScreenState extends ConsumerState<ImportPrivateKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _labelController = TextEditingController();
  bool _obscureKey = true;

  @override
  void dispose() {
    _keyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(importPrivateKeyNotifierProvider.notifier)
        .importPrivateKey(
          _keyController.text.trim(),
          _labelController.text.trim(),
        );
    if (success && mounted) {
      ref.invalidate(walletExistsProvider);
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(importPrivateKeyNotifierProvider);
    final isLoading = asyncState.isLoading;

    ref.listen(importPrivateKeyNotifierProvider, (_, next) {
      if (next.hasError) {
        showErrorSnackBar(context, next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: BackButton(
          color: context.colors.textSecondary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Import private key',
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
                    'Enter private key',
                    style: AppTextStyles.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste your hex-encoded private key below. '
                    'It will never leave this device.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PrivateKeyField(
                    controller: _keyController,
                    obscure: _obscureKey,
                    onToggleObscure: () => setState(() => _obscureKey = !_obscureKey),
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

class _PrivateKeyField extends StatelessWidget {
  const _PrivateKeyField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.mono.copyWith(color: context.colors.textPrimary),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Private key is required';
        final hex = v.trim().replaceFirst('0x', '');
        if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hex)) {
          return 'Must be a 64-character hex string (with or without 0x prefix)';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Private key',
        hintText: '0x...',
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: context.colors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: context.colors.textSecondary,
        ),
        filled: false,
        fillColor: context.colors.surface,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: context.colors.textSecondary,
            size: 20,
          ),
          onPressed: onToggleObscure,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
