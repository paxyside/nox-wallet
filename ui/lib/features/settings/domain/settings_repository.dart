// Domain models and abstract repository for settings.

/// Type of secret backing a wallet — domain-level enum, decoupled from proto.
enum SecretKind {
  unspecified,
  mnemonic,
  privateKey,
}

class WalletSettings {
  const WalletSettings({
    required this.address,
    required this.label,
    required this.secretKind,
  });

  final String address;
  final String label;
  final SecretKind secretKind;
}

class RevealedSecret {
  const RevealedSecret({required this.secret, required this.secretKind});
  final String secret;
  final SecretKind secretKind;
}

abstract class SettingsRepository {
  Future<WalletSettings> getWallet();
  Future<List<int>> exportKeystore(String passphrase);
  Future<RevealedSecret> revealSecret();
}
