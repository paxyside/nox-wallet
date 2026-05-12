import 'package:grpc/grpc.dart';
import 'package:wallet_proto/wallet/service.pbgrpc.dart';

class GrpcClient {
  GrpcClient._();

  static final GrpcClient instance = GrpcClient._();

  late final ClientChannel _channel;
  late final WalletServiceClient stub;

  void init({String host = '127.0.0.1', int port = 50055}) {
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = WalletServiceClient(_channel);
  }

  Future<void> dispose() => _channel.shutdown();
}
