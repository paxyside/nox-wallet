// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyFilterNotifierHash() => r'c0b2bad4f07b73e59d61cf537f4ddf25355d75e8';

/// See also [HistoryFilterNotifier].
@ProviderFor(HistoryFilterNotifier)
final historyFilterNotifierProvider =
    AutoDisposeNotifierProvider<HistoryFilterNotifier, HistoryFilter>.internal(
      HistoryFilterNotifier.new,
      name: r'historyFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoryFilterNotifier = AutoDisposeNotifier<HistoryFilter>;
String _$historyNotifierHash() => r'f5027159e2257827f44400cb16bae9d20bb39182';

/// See also [HistoryNotifier].
@ProviderFor(HistoryNotifier)
final historyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HistoryNotifier, HistoryState>.internal(
      HistoryNotifier.new,
      name: r'historyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoryNotifier = AutoDisposeAsyncNotifier<HistoryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
