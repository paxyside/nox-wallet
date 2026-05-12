import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/onboarding/domain/wallet_repository.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

class WalletGrpcRepository implements WalletRepository {
  const WalletGrpcRepository();

  @override
  Future<GeneratedWallet> generateWallet(String label, {bool wordCount24 = false}) async {
    final request = GenerateWalletRequest()
      ..label = label
      ..wordCount24 = wordCount24;
    final response = await GrpcClient.instance.stub.generateWallet(request);
    return createGeneratedWallet(address: response.wallet.address, mnemonic: response.mnemonic);
  }

  @override
  Future<void> importMnemonic(String mnemonic, String label, {String derivationPath = ''}) async {
    final request = ImportMnemonicRequest()
      ..mnemonic = mnemonic
      ..label = label
      ..derivationPath = derivationPath;
    await GrpcClient.instance.stub.importMnemonic(request);
  }

  @override
  Future<void> importPrivateKey(String privateKeyHex, String label) async {
    final request = ImportPrivateKeyRequest()
      ..privateKeyHex = privateKeyHex
      ..label = label;
    await GrpcClient.instance.stub.importPrivateKey(request);
  }

  @override
  Future<void> importKeystore(List<int> keystoreJson, String passphrase, String label) async {
    final request = ImportKeystoreRequest()
      ..keystoreJson = keystoreJson
      ..passphrase = passphrase
      ..label = label;
    await GrpcClient.instance.stub.importKeystore(request);
  }
}
