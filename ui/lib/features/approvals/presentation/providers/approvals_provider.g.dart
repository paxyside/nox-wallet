// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approvals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$approvalRepositoryHash() => r'857be405ad48f8430643485b46665f13b132b68b';

/// See also [approvalRepository].
@ProviderFor(approvalRepository)
final approvalRepositoryProvider = AutoDisposeProvider<ApprovalRepository>.internal(
  approvalRepository,
  name: r'approvalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$approvalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApprovalRepositoryRef = AutoDisposeProviderRef<ApprovalRepository>;
String _$approvalsNotifierHash() => r'4ffb7c3e2b39b6546a17b9148768b52c86309152';

/// Lists active ERC-20 allowances for the loaded wallet. Auto-disposed on
/// screen leave so the next visit re-queries the chain — these are
/// security-sensitive numbers and we don't want stale data.
///
/// Copied from [ApprovalsNotifier].
@ProviderFor(ApprovalsNotifier)
final approvalsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ApprovalsNotifier, List<TokenApproval>>.internal(
      ApprovalsNotifier.new,
      name: r'approvalsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$approvalsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApprovalsNotifier = AutoDisposeAsyncNotifier<List<TokenApproval>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
