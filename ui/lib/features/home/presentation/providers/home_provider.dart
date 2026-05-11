import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:nox/core/router/router.dart';
import 'package:nox/features/home/domain/home_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_provider.g.dart';

@riverpod
Future<HomeState> homeData(Ref ref) async {
  const repository = BalanceGrpcRepository();
  const useCase = HomeUseCase(repository);

  // Auto-refresh every 30 seconds by invalidating this provider.
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  try {
    return await useCase.execute();
  } on GrpcError catch (e) {
    if (e.code == StatusCode.notFound) {
      // Wallet deleted — redirect to onboarding.
      ref.invalidate(walletExistsProvider);
    }
    rethrow;
  }
}
