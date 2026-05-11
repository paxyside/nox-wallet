// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletRepositoryHash() => r'bab4ad7ffe40c131ff1fda1a4e81e0ce5f747f41';

/// See also [walletRepository].
@ProviderFor(walletRepository)
final walletRepositoryProvider = AutoDisposeProvider<WalletRepository>.internal(
  walletRepository,
  name: r'walletRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletRepositoryRef = AutoDisposeProviderRef<WalletRepository>;
String _$onboardingUseCaseHash() => r'96f46b8925e6bb0bb83ab91731eafbcbe59b5a43';

/// See also [onboardingUseCase].
@ProviderFor(onboardingUseCase)
final onboardingUseCaseProvider = AutoDisposeProvider<OnboardingUseCase>.internal(
  onboardingUseCase,
  name: r'onboardingUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingUseCaseRef = AutoDisposeProviderRef<OnboardingUseCase>;
String _$generateWalletNotifierHash() => r'5e0f214003e4a2d55ba629fa781e02ed6715227f';

/// See also [GenerateWalletNotifier].
@ProviderFor(GenerateWalletNotifier)
final generateWalletNotifierProvider =
    AutoDisposeNotifierProvider<GenerateWalletNotifier, AsyncValue<GeneratedWallet?>>.internal(
      GenerateWalletNotifier.new,
      name: r'generateWalletNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generateWalletNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GenerateWalletNotifier = AutoDisposeNotifier<AsyncValue<GeneratedWallet?>>;
String _$importMnemonicNotifierHash() => r'd56158a1f7b9fc9408149c4befa87daaa988e59e';

/// See also [ImportMnemonicNotifier].
@ProviderFor(ImportMnemonicNotifier)
final importMnemonicNotifierProvider =
    AutoDisposeNotifierProvider<ImportMnemonicNotifier, AsyncValue<void>>.internal(
      ImportMnemonicNotifier.new,
      name: r'importMnemonicNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importMnemonicNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImportMnemonicNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$importPrivateKeyNotifierHash() => r'661c047b6c0f3199147c840da8de6645040dec59';

/// See also [ImportPrivateKeyNotifier].
@ProviderFor(ImportPrivateKeyNotifier)
final importPrivateKeyNotifierProvider =
    AutoDisposeNotifierProvider<ImportPrivateKeyNotifier, AsyncValue<void>>.internal(
      ImportPrivateKeyNotifier.new,
      name: r'importPrivateKeyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importPrivateKeyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImportPrivateKeyNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$importKeystoreNotifierHash() => r'b3c56ada265d0e4523ee041cba8d3bb4bdebf6b2';

/// See also [ImportKeystoreNotifier].
@ProviderFor(ImportKeystoreNotifier)
final importKeystoreNotifierProvider =
    AutoDisposeNotifierProvider<ImportKeystoreNotifier, AsyncValue<void>>.internal(
      ImportKeystoreNotifier.new,
      name: r'importKeystoreNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importKeystoreNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImportKeystoreNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
