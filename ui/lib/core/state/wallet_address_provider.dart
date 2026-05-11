import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_address_provider.g.dart';

/// Loaded wallet address, kept here so any feature can depend on it
/// without each one round-tripping to gRPC themselves.
///
/// Returns an empty string if the call fails — callers should treat that
/// as "no wallet loaded" and short-circuit.
@riverpod
Future<String> walletAddress(Ref ref) async {
  try {
    const repo = BalanceGrpcRepository();
    final info = await repo.getWallet();
    return info.address;
  } on Object catch (_) {
    return '';
  }
}
