import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/features/approvals/data/approval_grpc_repository.dart';
import 'package:nox/features/approvals/domain/approval.dart';
import 'package:nox/features/approvals/domain/approval_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'approvals_provider.g.dart';

@riverpod
ApprovalRepository approvalRepository(Ref ref) => const ApprovalGrpcRepository();

/// Lists active ERC-20 allowances for the loaded wallet. Auto-disposed on
/// screen leave so the next visit re-queries the chain — these are
/// security-sensitive numbers and we don't want stale data.
@riverpod
class ApprovalsNotifier extends _$ApprovalsNotifier {
  @override
  Future<List<TokenApproval>> build() {
    return ref.read(approvalRepositoryProvider).list();
  }

  /// Calls revoke (approve(spender, 0)) and refreshes the list. Returns the
  /// tx hash so the caller can show a "View on Etherscan" snackbar.
  Future<String> revoke(String tokenAddress, String spender) async {
    final hash = await ref.read(approvalRepositoryProvider).revoke(tokenAddress, spender);
    // Optimistically drop the row from the local list — the on-chain state
    // is now zero, no point keeping it shown.
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current
          .where(
            (a) =>
                !(a.tokenAddress.toLowerCase() == tokenAddress.toLowerCase() &&
                    a.spender.toLowerCase() == spender.toLowerCase()),
          )
          .toList(),
    );
    return hash;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(approvalRepositoryProvider).list());
  }
}
