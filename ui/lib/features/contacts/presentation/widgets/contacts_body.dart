import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/pagination.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_empty_state.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_list.dart';
import 'package:nox/features/contacts/presentation/widgets/contacts_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

const _kContactsPageSize = 5;

class ContactsBody extends ConsumerStatefulWidget {
  const ContactsBody({super.key});

  @override
  ConsumerState<ContactsBody> createState() => _ContactsBodyState();
}

class _ContactsBodyState extends ConsumerState<ContactsBody> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Reset page whenever search or sort changes.
    ref
      ..listenManual<String>(contactsSearchProvider, (prev, next) {
        if (mounted) setState(() => _page = 0);
      })
      ..listenManual<ContactSortField>(contactsSortProvider, (prev, next) {
        if (mounted) setState(() => _page = 0);
      });
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(contactsNotifierProvider).valueOrNull ?? [];
    final filtered = ref.watch(filteredContactsProvider);
    final query = ref.watch(contactsSearchProvider);

    final totalPages = (filtered.length / _kContactsPageSize).ceil();
    final safePage = totalPages == 0 ? 0 : _page.clamp(0, totalPages - 1);
    final start = safePage * _kContactsPageSize;
    final end = (start + _kContactsPageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <Contact>[] : filtered.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContactsHeader(total: all.length),
        Expanded(
          child: all.isEmpty
              ? const ContactEmptyState()
              : filtered.isEmpty
              ? _NoResults(query: query)
              : ContactList(contacts: pageItems),
        ),
        if (totalPages > 1)
          AppPagination(
            current: safePage,
            total: totalPages,
            onPage: (p) => setState(() => _page = p),
          ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: context.colors.textDisabled),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
