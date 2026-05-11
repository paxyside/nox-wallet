// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncStatusNotifierHash() => r'ed0799ebacfbf1117a81b2da3cd9cebf6290306d';

/// Polls the backend every 30 seconds via [BalanceRepository] and surfaces
/// connectivity status to the UI. Goes through the repository abstraction so
/// no proto/gRPC details leak into providers.
///
/// Copied from [SyncStatusNotifier].
@ProviderFor(SyncStatusNotifier)
final syncStatusNotifierProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>.internal(
  SyncStatusNotifier.new,
  name: r'syncStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncStatusNotifier = Notifier<SyncStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
