import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';

class ContactFormDialog extends ConsumerStatefulWidget {
  const ContactFormDialog({super.key, this.contact, this.initialAddress});

  /// When non-null, the dialog is in edit mode.
  final Contact? contact;

  /// Pre-fills the address field when creating a new contact.
  final String? initialAddress;

  @override
  ConsumerState<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends ConsumerState<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _noteCtrl;
  bool _loading = false;

  bool get _isEdit => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.contact?.name ?? '');
    _addressCtrl = TextEditingController(
      text: widget.contact?.address ?? widget.initialAddress ?? '',
    );
    _noteCtrl = TextEditingController(text: widget.contact?.note ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final notifier = ref.read(contactsNotifierProvider.notifier);
      if (_isEdit) {
        await notifier.edit(
          widget.contact!.id,
          _nameCtrl.text.trim(),
          _addressCtrl.text.trim(),
          _noteCtrl.text.trim(),
        );
      } else {
        await notifier.create(
          _nameCtrl.text.trim(),
          _addressCtrl.text.trim(),
          _noteCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) AppSnackBar.error(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'Edit Contact' : 'Add Contact', style: AppTextStyles.h3),
                const SizedBox(height: 24),
                _FormField(
                  label: 'Name',
                  controller: _nameCtrl,
                  hint: 'e.g. Alice',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Address',
                  controller: _addressCtrl,
                  hint: '0x...',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Address is required';
                    }
                    final hex = v.trim();
                    final hexRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');
                    if (!hexRegex.hasMatch(hex)) {
                      return 'Enter a valid 0x Ethereum address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Note',
                  controller: _noteCtrl,
                  hint: 'Optional note…',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Text(_isEdit ? 'Save' : 'Add Contact'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
            filled: false,
            fillColor: AppColors.surfaceHigh,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
