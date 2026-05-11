/// Optional EIP-1559 overrides shared by Send and Swap repositories.
///
/// `null` on either field means "use the network suggestion" — set both for
/// full custom-gas behaviour. Both fields are decimal-gwei strings, the
/// conventional format throughout the API.
class GasOverride {
  const GasOverride({this.priorityGwei, this.maxGwei});

  final String? priorityGwei;
  final String? maxGwei;

  bool get isEmpty => priorityGwei == null && maxGwei == null;

  static const auto = GasOverride();
}
