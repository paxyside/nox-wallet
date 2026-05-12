import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/features/approvals/domain/approval.dart';
import 'package:nox/features/approvals/domain/approval_repository.dart';
import 'package:wallet_proto/wallet/service.pb.dart'
    show ListApprovalsRequest, RevokeApprovalRequest;

class ApprovalGrpcRepository implements ApprovalRepository {
  const ApprovalGrpcRepository();

  @override
  Future<List<TokenApproval>> list() async {
    final response = await GrpcClient.instance.stub.listApprovals(ListApprovalsRequest());
    return response.approvals
        .map(
          (a) => TokenApproval(
            tokenAddress: a.tokenAddress,
            tokenSymbol: a.tokenSymbol,
            tokenName: a.tokenName,
            tokenDecimals: a.tokenDecimals,
            spender: a.spender,
            spenderLabel: a.spenderLabel,
            amountRaw: a.amountRaw,
            amountHuman: a.amountHuman,
            tokenLogoUrl: a.tokenLogoUrl,
          ),
        )
        .toList();
  }

  @override
  Future<String> revoke(String tokenAddress, String spender) async {
    final response = await GrpcClient.instance.stub.revokeApproval(
      RevokeApprovalRequest()
        ..tokenAddress = tokenAddress
        ..spender = spender,
    );
    return response.receipt.txHash;
  }
}
