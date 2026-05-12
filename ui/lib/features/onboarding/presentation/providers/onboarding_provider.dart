import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/features/onboarding/data/wallet_grpc_repository.dart';
import 'package:nox/features/onboarding/domain/onboarding_usecase.dart';
import 'package:nox/features/onboarding/domain/wallet_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

@riverpod
WalletRepository walletRepository(Ref ref) => const WalletGrpcRepository();

@riverpod
OnboardingUseCase onboardingUseCase(Ref ref) =>
    OnboardingUseCase(ref.watch(walletRepositoryProvider));

// State for generateWallet flow — holds the resulting wallet once created.
@riverpod
class GenerateWalletNotifier extends _$GenerateWalletNotifier {
  @override
  AsyncValue<GeneratedWallet?> build() => const AsyncData(null);

  Future<void> generateWallet(String label) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(onboardingUseCaseProvider).generateWallet(label));
  }

  void reset() => state = const AsyncData(null);
}

// State for importMnemonic flow.
@riverpod
class ImportMnemonicNotifier extends _$ImportMnemonicNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> importMnemonic(String mnemonic, String label, {String derivationPath = ''}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(onboardingUseCaseProvider)
          .importMnemonic(mnemonic, label, derivationPath: derivationPath),
    );
    return !state.hasError;
  }
}

// State for importPrivateKey flow.
@riverpod
class ImportPrivateKeyNotifier extends _$ImportPrivateKeyNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> importPrivateKey(String privateKeyHex, String label) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(onboardingUseCaseProvider).importPrivateKey(privateKeyHex, label),
    );
    return !state.hasError;
  }
}

// State for importKeystore flow.
@riverpod
class ImportKeystoreNotifier extends _$ImportKeystoreNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> importKeystore(List<int> keystoreJson, String passphrase, String label) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(onboardingUseCaseProvider).importKeystore(keystoreJson, passphrase, label),
    );
    return !state.hasError;
  }
}
