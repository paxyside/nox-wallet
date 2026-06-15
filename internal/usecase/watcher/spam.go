package watcher

import "strings"

// isSpamTransaction reports whether a transaction is address-poisoning
// spam that should be dropped before it ever becomes a notification.
//
// The attack: anyone can deploy a counterfeit ERC-20 contract and emit
// a fake `Transfer(from=victim, to=lookalike, value=…)` log. No real
// funds move — the attacker only pays gas — but Alchemy's
// getAssetTransfers returns the log because the victim's address
// appears in it, so the watcher would otherwise surface it as a "Sent"
// notification. The goal is to get a lookalike address into the
// victim's history so they later copy-paste it and send real funds to
// the attacker.
//
// Defence: a genuine ERC-20 can only emit its OWN Transfer events, so a
// fake "USDC" transfer necessarily comes from a contract whose address
// is NOT the canonical USDC address. We treat any transaction that
// moves an unverified token — a contract absent from the embedded
// verified list (Uniswap Default Token List) — as spam, unless we
// initiated it ourselves.
//
// Two carve-outs keep false positives at zero:
//   - IsOurs transactions are never spam: we signed them, so even a
//     swap into a long-tail unlisted token the user deliberately chose
//     stays visible.
//   - Pure-ETH transactions (no ERC-20 leg) are never dropped here —
//     the fake-token vector doesn't apply to native transfers.
//
// Fails open: if no token lookup is wired the function returns false
// (keep everything) rather than silently hiding real activity.
func (u *Usecase) isSpamTransaction(tx *TransactionData) bool {
	if tx == nil || tx.IsOurs || u.tokenLookup == nil {
		return false
	}

	for _, m := range tx.Movements {
		if m.ContractAddress == "" {
			continue // native ETH leg — not a counterfeit-token vector
		}

		if _, verified := u.tokenLookup(strings.ToLower(m.ContractAddress)); !verified {
			return true // unverified ERC-20 + not ours → address-poisoning spam
		}
	}

	return false
}
