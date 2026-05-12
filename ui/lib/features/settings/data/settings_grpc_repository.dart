import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/settings/domain/settings_repository.dart';
import 'package:wallet_proto/wallet/service.pb.dart';
import 'package:wallet_proto/wallet/wallet/wallet.pbenum.dart' as pbe;

/// Maps proto `SecretType` to the domain `SecretKind`. The mapping is local
/// to the data layer so domain code stays free of proto dependencies.
SecretKind _secretKindFromProto(pbe.SecretType value) {
  if (value == pbe.SecretType.SECRET_TYPE_MNEMONIC) return SecretKind.mnemonic;
  if (value == pbe.SecretType.SECRET_TYPE_PRIVATE_KEY) {
    return SecretKind.privateKey;
  }
  return SecretKind.unspecified;
}

class SettingsGrpcRepository implements SettingsRepository {
  const SettingsGrpcRepository();

  @override
  Future<WalletSettings> getWallet() async {
    final response = await GrpcClient.instance.stub.getWallet(GetWalletRequest());
    return WalletSettings(
      address: response.wallet.address,
      label: response.wallet.label,
      secretKind: _secretKindFromProto(response.wallet.secretType),
    );
  }

  @override
  Future<List<int>> exportKeystore(String passphrase) async {
    final request = ExportKeystoreRequest()..passphrase = passphrase;
    final response = await GrpcClient.instance.stub.exportKeystore(request);
    return response.keystoreJson;
  }

  @override
  Future<RevealedSecret> revealSecret() async {
    final response = await GrpcClient.instance.stub.revealSecret(RevealSecretRequest());
    return RevealedSecret(
      secret: response.secret,
      secretKind: _secretKindFromProto(response.secretType),
    );
  }
}
