// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentActivityHash() => r'5e5ece0abf4bf729d58030bb6ed4b0b76ec05ebb';

/// Loads up to 5 most recent transactions for the dashboard.
///
/// We over-fetch (`limit: 12`) because the server collapses two same-hash
/// swap legs into a single merged entry — asking for 5 raw rows can yield
/// only ~3 visible items. 12 raw rows comfortably covers 5 merged entries
/// even when most of them are swaps.
///
/// Depends on [homeDataProvider] for the wallet address — refreshes together.
///
/// Copied from [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider = AutoDisposeFutureProvider<List<Transaction>>.internal(
  recentActivity,
  name: r'recentActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentActivityRef = AutoDisposeFutureProviderRef<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
