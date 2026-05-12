import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/utils/error_message.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_skeleton.dart';
import 'package:nox/features/contacts/presentation/widgets/contacts_body.dart';
import 'package:nox/features/contacts/presentation/widgets/contacts_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: contactsAsync.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ContactsHeader(total: 0, isLoading: true),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, _) => const SkeletonCard(),
              ),
            ),
          ],
        ),
        error: (e, _) => _ErrorState(error: errorMessage(e)),
        data: (_) => const ContactsBody(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: context.colors.error),
          const SizedBox(height: 12),
          Text(
            'Failed to load contacts',
            style: AppTextStyles.h3.copyWith(color: context.colors.error),
          ),
          const SizedBox(height: 8),
          Text(error, style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
