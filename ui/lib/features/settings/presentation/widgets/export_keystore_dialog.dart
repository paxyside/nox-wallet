import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/settings/presentation/providers/settings_provider.dart';

class ExportKeystoreDialog extends ConsumerStatefulWidget {
  const ExportKeystoreDialog({super.key});

  @override
  ConsumerState<ExportKeystoreDialog> createState() => _ExportKeystoreDialogState();
}

class _ExportKeystoreDialogState extends ConsumerState<ExportKeystoreDialog> {
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassphrase = true;
  bool _obscureConfirm = true;

  // Holds the exported JSON string after a successful export.
  String? _exportedJson;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onExport() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(exportKeystoreNotifierProvider.notifier);
    final success = await notifier.exportKeystore(_passphraseController.text);

    if (!mounted) return;

    if (success) {
      final bytes = ref.read(exportKeystoreNotifierProvider).value;
      if (bytes != null && bytes.isNotEmpty) {
        setState(() {
          _exportedJson = String.fromCharCodes(bytes);
        });
      }
    } else {
      final error = ref.read(exportKeystoreNotifierProvider).error;
      AppSnackBar.error(context, 'Export failed: $error');
    }
  }

  void _copyToClipboard() {
    if (_exportedJson == null) return;
    unawaited(Clipboard.setData(ClipboardData(text: _exportedJson!)));
    AppSnackBar.info(context, 'Keystore JSON copied.');
  }

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(exportKeystoreNotifierProvider);
    final isLoading = exportState.isLoading;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Export Keystore', style: AppTextStyles.h3),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () {
                      ref.read(exportKeystoreNotifierProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep this file safe. Anyone with this file and '
                        'passphrase can access your funds.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_exportedJson == null) ...[
                // ---------- Input form ----------
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Passphrase field
                      _buildLabel('Passphrase'),
                      const SizedBox(height: 6),
                      _PassphraseField(
                        controller: _passphraseController,
                        obscure: _obscurePassphrase,
                        onToggle: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter a passphrase';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm passphrase field
                      _buildLabel('Confirm Passphrase'),
                      const SizedBox(height: 6),
                      _PassphraseField(
                        controller: _confirmController,
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v != _passphraseController.text) {
                            return 'Passphrases do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // Export button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : _onExport,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Export'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // ---------- Success — show JSON ----------
                const Text('Keystore JSON', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),

                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(_exportedJson!, style: AppTextStyles.monoSmall),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy to Clipboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: AppTextStyles.labelMedium);
}

class _PassphraseField extends StatelessWidget {
  const _PassphraseField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        filled: false,
        fillColor: AppColors.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: 18,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
