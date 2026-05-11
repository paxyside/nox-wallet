import 'package:nox/features/contacts/domain/contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> list();
  Future<Contact> create(String name, String address, String note);
  Future<Contact> update(String id, String name, String address, String note);
  Future<void> favorite(String id, {required bool favorite});
  Future<void> delete(String id);
}
