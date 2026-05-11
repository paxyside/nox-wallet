// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hideBalancesHash() => r'bdefaf01961517709eeb73f13227a55667faf929';

/// When `true`, all monetary amounts in the UI are masked as `***`.
/// Useful when screen-sharing or filming a demo.
///
/// Copied from [HideBalances].
@ProviderFor(HideBalances)
final hideBalancesProvider = NotifierProvider<HideBalances, bool>.internal(
  HideBalances.new,
  name: r'hideBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hideBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HideBalances = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
