// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() => r'81f9613f14b672a461f0865d84f664e2ac6ca8cb';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = AutoDisposeProvider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = AutoDisposeProviderRef<SettingsRepository>;
String _$walletSettingsHash() => r'8ca1b057043619e0bcccc3a75e473958427c8555';

/// See also [walletSettings].
@ProviderFor(walletSettings)
final walletSettingsProvider = AutoDisposeFutureProvider<WalletSettings>.internal(
  walletSettings,
  name: r'walletSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletSettingsRef = AutoDisposeFutureProviderRef<WalletSettings>;
String _$exportKeystoreNotifierHash() => r'bf2ce936a4a33c0998dbcfea67958f861e118da1';

/// See also [ExportKeystoreNotifier].
@ProviderFor(ExportKeystoreNotifier)
final exportKeystoreNotifierProvider =
    AutoDisposeNotifierProvider<ExportKeystoreNotifier, AsyncValue<List<int>?>>.internal(
      ExportKeystoreNotifier.new,
      name: r'exportKeystoreNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exportKeystoreNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExportKeystoreNotifier = AutoDisposeNotifier<AsyncValue<List<int>?>>;
String _$revealSecretNotifierHash() => r'f19e7f8adde0b956e7e5c36800b8fa3e505fa63e';

/// See also [RevealSecretNotifier].
@ProviderFor(RevealSecretNotifier)
final revealSecretNotifierProvider =
    AutoDisposeNotifierProvider<RevealSecretNotifier, AsyncValue<RevealedSecret?>>.internal(
      RevealSecretNotifier.new,
      name: r'revealSecretNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$revealSecretNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RevealSecretNotifier = AutoDisposeNotifier<AsyncValue<RevealedSecret?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
