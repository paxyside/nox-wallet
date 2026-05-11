import 'package:nox/features/approvals/domain/approval.dart';

abstract interface class ApprovalRepository {
  Future<List<TokenApproval>> list();

  /// Revokes the allowance by submitting `approve(spender, 0)`. Returns the
  /// transaction hash on success.
  Future<String> revoke(String tokenAddress, String spender);
}
