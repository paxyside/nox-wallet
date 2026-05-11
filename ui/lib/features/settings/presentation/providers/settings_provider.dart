import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/features/settings/data/settings_grpc_repository.dart';
import 'package:nox/features/settings/domain/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export '../../domain/settings_repository.dart' show RevealedSecret;

part 'settings_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

@riverpod
SettingsRepository settingsRepository(Ref ref) => const SettingsGrpcRepository();

// ---------------------------------------------------------------------------
// Wallet info — loads on init
// ---------------------------------------------------------------------------

@riverpod
Future<WalletSettings> walletSettings(Ref ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getWallet();
}

// ---------------------------------------------------------------------------
// Export keystore notifier
// ---------------------------------------------------------------------------

@riverpod
class ExportKeystoreNotifier extends _$ExportKeystoreNotifier {
  @override
  AsyncValue<List<int>?> build() => const AsyncData(null);

  Future<bool> exportKeystore(String passphrase) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).exportKeystore(passphrase),
    );
    return !state.hasError;
  }

  void reset() => state = const AsyncData(null);
}

// ---------------------------------------------------------------------------
// Reveal secret notifier
// ---------------------------------------------------------------------------

@riverpod
class RevealSecretNotifier extends _$RevealSecretNotifier {
  @override
  AsyncValue<RevealedSecret?> build() => const AsyncData(null);

  Future<bool> reveal() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).revealSecret(),
    );
    return !state.hasError;
  }

  void clear() => state = const AsyncData(null);
}
