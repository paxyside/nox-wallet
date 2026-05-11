import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/wallet_events/data/wallet_events_grpc_repository.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:nox/core/wallet_events/domain/wallet_event.dart';

part 'wallet_events_provider.g.dart';

/// Repository for wallet event subscriptions.
@Riverpod(keepAlive: true)
WalletEventsRepository walletEventsRepository(Ref ref) => const WalletEventsGrpcRepository();

/// Long-running stream of wallet events. Stays alive for the lifetime of the
/// app so subscribers don't lose events when the screen disposes.
@Riverpod(keepAlive: true)
Stream<WalletEvent> walletEvents(Ref ref) => ref.watch(walletEventsRepositoryProvider).watch();
