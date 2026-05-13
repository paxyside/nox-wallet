// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$swappableAssetsHash() => r'bcc97ecea29fbe29532da4b5491ae52eb980cf7c';

/// Build the swap asset list directly from the user's wallet —
/// native ETH plus every watched ERC-20. Logo URLs are pre-stamped
/// by the backend, so no separate lookup or hardcoded list is needed.
///
/// Implication: to swap *into* a token the user doesn't yet own, they
/// have to Add Token first. That's the trade-off for not maintaining
/// a hand-curated swap-only list — and it nudges users to confirm the
/// contract address (anti-spam) before any swap can include it.
///
/// Copied from [swappableAssets].
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
