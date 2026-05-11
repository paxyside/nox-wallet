import 'package:flutter/foundation.dart';

@immutable
class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.address,
    required this.note,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String address;
  final String note;
  final bool isFavorite;
  final DateTime createdAt;

  Contact copyWith({
    String? name,
    String? address,
    String? note,
    bool? isFavorite,
  }) => Contact(
    id: id,
    name: name ?? this.name,
    address: address ?? this.address,
    note: note ?? this.note,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Contact && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
