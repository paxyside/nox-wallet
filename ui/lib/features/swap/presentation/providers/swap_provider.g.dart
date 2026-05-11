// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$swappableAssetsHash() => r'4f00cdd26605791603416a44aa369058c6a72434';

/// See also [swappableAssets].
@ProviderFor(swappableAssets)
final swappableAssetsProvider = AutoDisposeFutureProvider<List<SwapAsset>>.internal(
  swappableAssets,
  name: r'swappableAssetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swappableAssetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SwappableAssetsRef = AutoDisposeFutureProviderRef<List<SwapAsset>>;
String _$swapRepositoryHash() => r'98b78a5d13005a46cb8380b9a6c19a677eed5471';

/// See also [swapRepository].
@ProviderFor(swapRepository)
final swapRepositoryProvider = AutoDisposeProvider<SwapRepository>.internal(
  swapRepository,
  name: r'swapRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swapRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SwapRepositoryRef = AutoDisposeProviderRef<SwapRepository>;
String _$swapNotifierHash() => r'043a6a60bdd193046c8690af92dabd2363faf37d';

/// See also [SwapNotifier].
@ProviderFor(SwapNotifier)
final swapNotifierProvider = AutoDisposeNotifierProvider<SwapNotifier, SwapState>.internal(
  SwapNotifier.new,
  name: r'swapNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swapNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwapNotifier = AutoDisposeNotifier<SwapState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
