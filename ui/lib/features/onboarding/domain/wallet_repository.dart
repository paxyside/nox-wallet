abstract class GeneratedWallet {
  String get address;
  String get mnemonic;
}

class _GeneratedWallet implements GeneratedWallet {
  const _GeneratedWallet({required this.address, required this.mnemonic});

  @override
  final String address;

  @override
  final String mnemonic;
}

GeneratedWallet createGeneratedWallet({required String address, required String mnemonic}) =>
    _GeneratedWallet(address: address, mnemonic: mnemonic);

abstract class WalletRepository {
  Future<GeneratedWallet> generateWallet(String label, {bool wordCount24 = false});

  Future<void> importMnemonic(String mnemonic, String label, {String derivationPath = ''});

  Future<void> importPrivateKey(String privateKeyHex, String label);

  Future<void> importKeystore(List<int> keystoreJson, String passphrase, String label);
}
