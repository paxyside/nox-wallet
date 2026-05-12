import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/themed_dropdown.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_form_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class ContactsHeader extends ConsumerStatefulWidget {
  const ContactsHeader({required this.total, this.isLoading = false, super.key});
  final int total;
  final bool isLoading;

  @override
  ConsumerState<ContactsHeader> createState() => _ContactsHeaderState();
}

class _ContactsHeaderState extends ConsumerState<ContactsHeader> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Title + count ─────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contacts', style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary)),
              // Always render the subtitle line so the column stays two-line
              // tall (matching the Tokens header height).
              Text(
                widget.total > 0 ? '${widget.total} saved' : '',
                style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // ── Search ────────────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _ctrl,
              enabled: !widget.isLoading,
              onChanged: (v) => ref.read(contactsSearchProvider.notifier).updateQuery(v),
              style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or address…',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textDisabled),
                prefixIcon: Icon(Icons.search, size: 16, color: context.colors.textSecondary),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 14, color: context.colors.textSecondary),
                        onPressed: () {
                          _ctrl.clear();
                          ref.read(contactsSearchProvider.notifier).clear();
                        },
                      )
                    : null,
                filled: false,
                fillColor: context.colors.surfaceHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.primary, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Sort ──────────────────────────────────────────────────────────
          if (!widget.isLoading) const _SortButton(),

          const SizedBox(width: 12),

          // ── Add ───────────────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: widget.isLoading ? null : () => _showAdd(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.textPrimary,
              disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdd(BuildContext context) async {
    final result = await showAppDialog<bool>(
      context: context,
      builder: (_) => const ContactFormDialog(),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, 'Contact added.');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _SortButton extends ConsumerWidget {
  const _SortButton();

  static const Map<ContactSortField, String> _labels = {
    ContactSortField.name: 'By name',
    ContactSortField.favorites: 'Favorites',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(contactsSortProvider);
    return ThemedDropdown<ContactSortField>(
      value: current,
      width: 150,
      leadingIcon: Icons.sort_rounded,
      items: [
        for (final entry in _labels.entries)
          ThemedDropdownItem(value: entry.key, label: entry.value),
      ],
      onChanged: (v) => ref.read(contactsSortProvider.notifier).selectField(v),
    );
  }
}
