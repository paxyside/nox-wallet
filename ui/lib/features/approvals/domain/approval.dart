/// Domain model for an active ERC-20 allowance the wallet has granted.
///
/// Returned from the backend's `ListApprovals` RPC. Both the raw amount
/// (uint256 wei string) and a human-readable form are pre-formatted on the
/// server so the UI doesn't need to know token decimals.
class TokenApproval {
  const TokenApproval({
    required this.tokenAddress,
    required this.tokenSymbol,
    required this.tokenName,
    required this.tokenDecimals,
    required this.spender,
    required this.spenderLabel,
    required this.amountRaw,
    required this.amountHuman,
    this.tokenLogoUrl = '',
  });

  final String tokenAddress;
  final String tokenSymbol;
  final String tokenName;
  final int tokenDecimals;

  /// Raw checksummed address of the contract granted the allowance.
  final String spender;

  /// Human-readable label for the spender — "Uniswap V3" / "1inch v5" / a
  /// truncated 0x... fallback for anything not in the known-routers map.
  final String spenderLabel;

  /// Raw uint256 wei string. Useful when the UI needs to detect "Unlimited"
  /// (max-uint256) or compare against a future allowance change.
  final String amountRaw;

  /// Pre-formatted amount: "Unlimited" or "12.34 USDC".
  final String amountHuman;

  /// Logo URL stamped by the backend from the embedded Uniswap
  /// Default Token List. Empty for unverified contracts — UI falls
  /// back to a letter avatar.
  final String tokenLogoUrl;

  /// Stable identity for ListView keys.
  String get id => '$tokenAddress:$spender';
}
