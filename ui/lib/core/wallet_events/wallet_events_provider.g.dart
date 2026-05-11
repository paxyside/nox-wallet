// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletEventsRepositoryHash() => r'42b163362cd296b5a52e6b11d877a35a94297b94';

/// Repository for wallet event subscriptions.
///
/// Copied from [walletEventsRepository].
@ProviderFor(walletEventsRepository)
final walletEventsRepositoryProvider = Provider<WalletEventsRepository>.internal(
  walletEventsRepository,
  name: r'walletEventsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletEventsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletEventsRepositoryRef = ProviderRef<WalletEventsRepository>;
String _$walletEventsHash() => r'bcd9c2a1aa602a32d7501e0e5ae46d0da1b14a73';

/// Long-running stream of wallet events. Stays alive for the lifetime of the
/// app so subscribers don't lose events when the screen disposes.
///
/// Copied from [walletEvents].
@ProviderFor(walletEvents)
final walletEventsProvider = StreamProvider<WalletEvent>.internal(
  walletEvents,
  name: r'walletEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletEventsRef = StreamProviderRef<WalletEvent>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
