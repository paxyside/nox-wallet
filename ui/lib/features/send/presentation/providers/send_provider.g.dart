// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sendRepositoryHash() => r'd11ce8b573664a6c20b0fd8e3e5fb2259c59f71d';

/// See also [sendRepository].
@ProviderFor(sendRepository)
final sendRepositoryProvider = AutoDisposeProvider<SendRepository>.internal(
  sendRepository,
  name: r'sendRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sendRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SendRepositoryRef = AutoDisposeProviderRef<SendRepository>;
String _$sendUseCaseHash() => r'27b7d413864c6a6fd1674b6638731508fb59f5e4';

/// See also [sendUseCase].
@ProviderFor(sendUseCase)
final sendUseCaseProvider = AutoDisposeProvider<SendUseCase>.internal(
  sendUseCase,
  name: r'sendUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sendUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SendUseCaseRef = AutoDisposeProviderRef<SendUseCase>;
String _$balanceRepositoryHash() => r'0fce1a9e3db88960af29442eea2e715754b5987f';

/// Repository for ETH + token balance lookups.
///
/// Copied from [balanceRepository].
@ProviderFor(balanceRepository)
final balanceRepositoryProvider = AutoDisposeProvider<BalanceRepository>.internal(
  balanceRepository,
  name: r'balanceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$balanceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BalanceRepositoryRef = AutoDisposeProviderRef<BalanceRepository>;
String _$sendableAssetsHash() => r'960594d56d5691462f0d397f2117821bd5b1da35';

/// Loads ETH + token balances for the asset selector.
///
/// Copied from [sendableAssets].
@ProviderFor(sendableAssets)
final sendableAssetsProvider = AutoDisposeFutureProvider<List<SendAsset>>.internal(
  sendableAssets,
  name: r'sendableAssetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sendableAssetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SendableAssetsRef = AutoDisposeFutureProviderRef<List<SendAsset>>;
String _$sendNotifierHash() => r'e81a9873615b1a2b306c6acf7842bb2f050f58fd';

/// See also [SendNotifier].
@ProviderFor(SendNotifier)
final sendNotifierProvider = AutoDisposeNotifierProvider<SendNotifier, SendState>.internal(
  SendNotifier.new,
  name: r'sendNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sendNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SendNotifier = AutoDisposeNotifier<SendState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
