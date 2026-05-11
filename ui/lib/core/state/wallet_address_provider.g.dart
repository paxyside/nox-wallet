// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_address_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletAddressHash() => r'1f79360963b0e4157db38fc50734a2cfe46a7d8b';

/// Loaded wallet address, kept here so any feature can depend on it
/// without each one round-tripping to gRPC themselves.
///
/// Returns an empty string if the call fails — callers should treat that
/// as "no wallet loaded" and short-circuit.
///
/// Copied from [walletAddress].
@ProviderFor(walletAddress)
final walletAddressProvider = AutoDisposeFutureProvider<String>.internal(
  walletAddress,
  name: r'walletAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletAddressRef = AutoDisposeFutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
