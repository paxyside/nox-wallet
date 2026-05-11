import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/ens/ens_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ens_provider.g.dart';

@riverpod
EnsRepository ensRepository(Ref ref) => const EnsGrpcRepository();

/// Returns the primary ENS name for [address], or empty string when none is
/// registered. The result is cached for the app's lifetime — names are
/// effectively static and we'd rather avoid hammering the resolver every
/// time the History scrolls.
///
/// On error, returns an empty string (treated as "no record") so the UI
/// silently falls back to a truncated 0x… address.
@Riverpod(keepAlive: true)
Future<String> ensReverse(Ref ref, String address) async {
  if (address.isEmpty || !address.startsWith('0x') || address.length != 42) {
    return '';
  }
  try {
    return await ref.read(ensRepositoryProvider).reverse(address);
  } on Object {
    return '';
  }
}
