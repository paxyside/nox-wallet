import 'package:flutter/material.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/presentation/widgets/contact_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contact list
// ─────────────────────────────────────────────────────────────────────────────

class ContactList extends StatelessWidget {
  const ContactList({required this.contacts, super.key});
  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (context, i) => const SizedBox(height: 8),
      // Key by contact.id so per-tile state (editing, hover) stays tied to
      // the actual contact when paginating, not to the row position.
      itemBuilder: (context, i) => ContactCard(key: ValueKey(contacts[i].id), contact: contacts[i]),
    );
  }
}
