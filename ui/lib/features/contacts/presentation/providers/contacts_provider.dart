import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/features/contacts/data/contact_grpc_repository.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/domain/contact_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts_provider.g.dart';

@riverpod
ContactRepository contactRepository(Ref ref) => const ContactGrpcRepository();

// ── Sort ──────────────────────────────────────────────────────────────────────

enum ContactSortField { name, favorites }

@riverpod
class ContactsSort extends _$ContactsSort {
  @override
  ContactSortField build() => ContactSortField.name;

  void selectField(ContactSortField field) {
    if (field == state) return;
    state = field;
  }
}

// ── Search ────────────────────────────────────────────────────────────────────

@riverpod
class ContactsSearch extends _$ContactsSearch {
  @override
  String build() => '';

  void updateQuery(String query) {
    if (query == state) return;
    state = query;
  }

  void clear() => state = '';
}

// ── Filtered + sorted list ────────────────────────────────────────────────────

@riverpod
List<Contact> filteredContacts(Ref ref) {
  final contacts = ref.watch(contactsNotifierProvider).valueOrNull ?? [];
  final query = ref.watch(contactsSearchProvider).toLowerCase().trim();
  final sort = ref.watch(contactsSortProvider);

  final result = query.isEmpty
      ? contacts
      : contacts
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query) || c.address.toLowerCase().contains(query),
            )
            .toList();

  return List.of(result)..sort((a, b) {
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return switch (sort) {
      ContactSortField.name => a.name.compareTo(b.name),
      ContactSortField.favorites => a.name.compareTo(b.name),
    };
  });
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  @override
  Future<List<Contact>> build() => ref.read(contactRepositoryProvider).list();

  Future<Contact?> create(String name, String address, String note) async {
    final contact = await ref.read(contactRepositoryProvider).create(name, address, note);
    state = AsyncData([...?state.valueOrNull, contact]);
    return contact;
  }

  Future<Contact?> edit(String id, String name, String address, String note) async {
    final updated = await ref.read(contactRepositoryProvider).update(id, name, address, note);
    state = AsyncData((state.valueOrNull ?? []).map((c) => c.id == id ? updated : c).toList());
    return updated;
  }

  Future<void> toggleFavorite(String id) async {
    final contacts = state.valueOrNull ?? [];
    final contact = contacts.firstWhere((c) => c.id == id);
    final next = !contact.isFavorite;

    // Optimistic update
    state = AsyncData(contacts.map((c) => c.id == id ? c.copyWith(isFavorite: next) : c).toList());
    try {
      await ref.read(contactRepositoryProvider).favorite(id, favorite: next);
    } catch (e) {
      state = AsyncData(contacts); // rollback
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncData(previous.where((c) => c.id != id).toList());
    try {
      await ref.read(contactRepositoryProvider).delete(id);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(contactRepositoryProvider).list());
  }
}

// ── Selected contact ──────────────────────────────────────────────────────────

@riverpod
class SelectedContactId extends _$SelectedContactId {
  @override
  String? build() => null;

  void select(String? id) {
    if (id == state) return;
    state = id;
  }
}
