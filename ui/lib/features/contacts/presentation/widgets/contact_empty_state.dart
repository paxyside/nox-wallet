import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
//
// The "Add Contact" CTA lives in the page header next to the search field, so
// we deliberately don't repeat it here — the header button is always visible
// regardless of whether the list has contents.
// ─────────────────────────────────────────────────────────────────────────────

class ContactEmptyState extends ConsumerWidget {
  const ContactEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(Icons.people_outline_rounded, size: 32, color: context.colors.textDisabled),
          ),
          const SizedBox(height: 20),
          Text(
            'No contacts yet',
            style: AppTextStyles.h3.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Save addresses you send to frequently.',
            style: AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
