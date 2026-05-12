import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_form_dialog.dart';

// ---------------------------------------------------------------------------
// "+ Add to contacts" chip
// ---------------------------------------------------------------------------

class AddToContactsChip extends StatefulWidget {
  const AddToContactsChip({required this.address, super.key});
  final String address;

  @override
  State<AddToContactsChip> createState() => _AddToContactsChipState();
}

class _AddToContactsChipState extends State<AddToContactsChip> {
  bool _hovered = false;

  Future<void> _openDialog() async {
    final saved = await showAppDialog<bool>(
      context: context,
      builder: (_) => ContactFormDialog(initialAddress: widget.address),
    );
    if (saved == true && mounted) {
      AppSnackBar.success(context, 'Contact saved.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _openDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? context.colors.primary.withValues(alpha: 0.12)
                : context.colors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 13, color: context.colors.primary),
              const SizedBox(width: 5),
              Text(
                'Add to contacts',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
