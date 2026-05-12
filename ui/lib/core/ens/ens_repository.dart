import 'package:nox/core/network/grpc_client.dart';
import 'package:wallet_proto/wallet/service.pb.dart';

/// Thin repository over the ENS gRPC methods. Both calls return an empty
/// string when the name / record isn't configured — UI treats that as a
/// "no ENS record" state, not an error.
abstract interface class EnsRepository {
  /// Returns the resolved address (lowercase 0x…) or empty string when the
  /// name has no resolver / no address record.
  Future<String> resolve(String name);

  /// Returns the primary ENS name for `address`, or empty string when none
  /// is set.
  Future<String> reverse(String address);
}

class EnsGrpcRepository implements EnsRepository {
  const EnsGrpcRepository();

  @override
  Future<String> resolve(String name) async {
    final response = await GrpcClient.instance.stub.resolveENS(ResolveENSRequest()..name = name);
    return response.address;
  }

  @override
  Future<String> reverse(String address) async {
    final response = await GrpcClient.instance.stub.reverseENS(
      ReverseENSRequest()..address = address,
    );
    return response.name;
  }
}
