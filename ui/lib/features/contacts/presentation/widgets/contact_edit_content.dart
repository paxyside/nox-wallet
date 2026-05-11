part of 'contact_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Edit form content (shown when _editing = true)
// ─────────────────────────────────────────────────────────────────────────────

class _EditContent extends StatelessWidget {
  const _EditContent({
    required this.nameCtrl,
    required this.addrCtrl,
    required this.noteCtrl,
    required this.saving,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addrCtrl;
  final TextEditingController noteCtrl;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.border),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.primary, width: 1.5),
    );
    final style = AppTextStyles.bodyMedium.copyWith(
      color: context.colors.textPrimary,
    );
    final hint = AppTextStyles.bodySmall.copyWith(
      color: context.colors.textDisabled,
    );
    InputDecoration decor(String h) => InputDecoration(
      hintText: h,
      hintStyle: hint,
      filled: false,
      fillColor: context.colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: focusedBorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field
        TextField(
          controller: nameCtrl,
          style: style,
          decoration: decor('Name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),

        // Address field
        TextField(
          controller: addrCtrl,
          style: AppTextStyles.monoSmall.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: decor('0x…'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),

        // Note field
        TextField(
          controller: noteCtrl,
          style: style,
          decoration: decor('Note (optional)'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSave(),
        ),
        const SizedBox(height: 12),

        // Buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: saving ? null : onCancel,
              style: TextButton.styleFrom(
                foregroundColor: context.colors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: saving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textPrimary,
                disabledBackgroundColor: context.colors.primary.withValues(
                  alpha: 0.4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTextStyles.labelMedium,
              ),
              child: saving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: context.colors.textPrimary,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
