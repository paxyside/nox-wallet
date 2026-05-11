import 'package:nox/features/onboarding/domain/wallet_repository.dart';

class OnboardingUseCase {
  const OnboardingUseCase(this._repository);

  final WalletRepository _repository;

  Future<GeneratedWallet> generateWallet(
    String label, {
    bool wordCount24 = false,
  }) => _repository.generateWallet(label, wordCount24: wordCount24);

  Future<void> importMnemonic(
    String mnemonic,
    String label, {
    String derivationPath = '',
  }) => _repository.importMnemonic(
    mnemonic,
    label,
    derivationPath: derivationPath,
  );

  Future<void> importPrivateKey(String privateKeyHex, String label) =>
      _repository.importPrivateKey(privateKeyHex, label);

  Future<void> importKeystore(
    List<int> keystoreJson,
    String passphrase,
    String label,
  ) => _repository.importKeystore(keystoreJson, passphrase, label);
}
