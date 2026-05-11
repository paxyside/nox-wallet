// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactRepositoryHash() => r'5e1c32c25b65ee5e5541d7b8829fde2e025969d6';

/// See also [contactRepository].
@ProviderFor(contactRepository)
final contactRepositoryProvider = AutoDisposeProvider<ContactRepository>.internal(
  contactRepository,
  name: r'contactRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactRepositoryRef = AutoDisposeProviderRef<ContactRepository>;
String _$filteredContactsHash() => r'ab0220088714ce41ec57e2bd6b2e0d8fca68479f';

/// See also [filteredContacts].
@ProviderFor(filteredContacts)
final filteredContactsProvider = AutoDisposeProvider<List<Contact>>.internal(
  filteredContacts,
  name: r'filteredContactsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredContactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredContactsRef = AutoDisposeProviderRef<List<Contact>>;
String _$contactsSortHash() => r'b8909873c86c85269a0696edd7d34b22df52aea8';

/// See also [ContactsSort].
@ProviderFor(ContactsSort)
final contactsSortProvider = AutoDisposeNotifierProvider<ContactsSort, ContactSortField>.internal(
  ContactsSort.new,
  name: r'contactsSortProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsSortHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContactsSort = AutoDisposeNotifier<ContactSortField>;
String _$contactsSearchHash() => r'7c2e6ea28c5258bf9d79632838a3685bc766ae31';

/// See also [ContactsSearch].
@ProviderFor(ContactsSearch)
final contactsSearchProvider = AutoDisposeNotifierProvider<ContactsSearch, String>.internal(
  ContactsSearch.new,
  name: r'contactsSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContactsSearch = AutoDisposeNotifier<String>;
String _$contactsNotifierHash() => r'0ae8536f4919a0ca1981326828d15f3cb875e922';

/// See also [ContactsNotifier].
@ProviderFor(ContactsNotifier)
final contactsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ContactsNotifier, List<Contact>>.internal(
      ContactsNotifier.new,
      name: r'contactsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsNotifier = AutoDisposeAsyncNotifier<List<Contact>>;
String _$selectedContactIdHash() => r'eadcb47cd36f4c774a083e8052f10e0f8d8bcbf8';

/// See also [SelectedContactId].
@ProviderFor(SelectedContactId)
final selectedContactIdProvider = AutoDisposeNotifierProvider<SelectedContactId, String?>.internal(
  SelectedContactId.new,
  name: r'selectedContactIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContactIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedContactId = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
