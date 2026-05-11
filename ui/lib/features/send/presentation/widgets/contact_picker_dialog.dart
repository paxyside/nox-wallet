import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';

// ---------------------------------------------------------------------------
// Contact picker dialog
// ---------------------------------------------------------------------------

class ContactPickerDialog extends ConsumerStatefulWidget {
  const ContactPickerDialog({super.key});

  @override
  ConsumerState<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends ConsumerState<ContactPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allContacts = ref.watch(contactsNotifierProvider).valueOrNull ?? [];

    final filtered = _query.isEmpty
        ? allContacts
        : allContacts.where((c) {
            final q = _query.toLowerCase();
            return c.name.toLowerCase().contains(q) || c.address.toLowerCase().contains(q);
          }).toList();

    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 18,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Choose recipient',
                    style: AppTextStyles.h3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: context.colors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or address…',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 6),
                      child: Icon(
                        Icons.search,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: context.colors.border),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          _query.isEmpty ? 'No contacts yet.' : 'No contacts match "$_query".',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: context.colors.border,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, i) => ContactPickerTile(contact: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactPickerTile extends StatefulWidget {
  const ContactPickerTile({required this.contact, this.onTap, super.key});
  final Contact contact;
  final VoidCallback? onTap;

  @override
  State<ContactPickerTile> createState() => _ContactPickerTileState();
}

class _ContactPickerTileState extends State<ContactPickerTile> {
  bool _hovered = false;

  String get _short {
    final a = widget.contact.address;
    if (a.length <= 16) return a;
    return '${a.substring(0, 8)}…${a.substring(a.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? () => Navigator.of(context).pop(widget.contact),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered ? context.colors.primary.withValues(alpha: 0.08) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.contact.name.isNotEmpty ? widget.contact.name[0].toUpperCase() : '?',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _short,
                      style: AppTextStyles.monoSmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: context.colors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
