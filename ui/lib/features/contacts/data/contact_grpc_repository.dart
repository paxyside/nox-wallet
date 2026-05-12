import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/contacts/domain/contact.dart';
import 'package:nox/features/contacts/domain/contact_repository.dart';
import 'package:wallet_proto/wallet/contact/contact.pb.dart' as $contactpb;
import 'package:wallet_proto/wallet/service.pb.dart';

class ContactGrpcRepository implements ContactRepository {
  const ContactGrpcRepository();

  @override
  Future<List<Contact>> list() async {
    final response = await GrpcClient.instance.stub.listContacts(ListContactsRequest());
    return response.contacts.map(_fromProto).toList();
  }

  @override
  Future<Contact> create(String name, String address, String note) async {
    final request = CreateContactRequest()
      ..name = name
      ..address = address
      ..note = note;
    final response = await GrpcClient.instance.stub.createContact(request);
    return _fromProto(response.contact);
  }

  @override
  Future<Contact> update(String id, String name, String address, String note) async {
    final request = UpdateContactRequest()
      ..id = id
      ..name = name
      ..address = address
      ..note = note;
    final response = await GrpcClient.instance.stub.updateContact(request);
    return _fromProto(response.contact);
  }

  @override
  Future<void> favorite(String id, {required bool favorite}) async {
    await GrpcClient.instance.stub.favoriteContact(
      FavoriteContactRequest()
        ..id = id
        ..favorite = favorite,
    );
  }

  @override
  Future<void> delete(String id) async {
    await GrpcClient.instance.stub.deleteContact(DeleteContactRequest()..id = id);
  }

  Contact _fromProto($contactpb.Contact proto) => Contact(
    id: proto.id,
    name: proto.name,
    address: proto.address,
    note: proto.note,
    isFavorite: proto.isFavorite,
    createdAt: proto.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(proto.createdAt.seconds.toInt() * 1000)
        : DateTime.fromMillisecondsSinceEpoch(0),
  );
}
