package ethkit

import (
	"context"
	"errors"
	"fmt"
	"strings"

	goens "github.com/wealdtech/go-ens/v3"
)

// ErrENSNotFound is returned when a name resolves to nothing or an address
// has no reverse record. Callers can use it to keep the UI quiet — "not
// configured" is a normal state, not an error to bubble.
var ErrENSNotFound = errors.New("ethkit: ENS name not found")

// IsENSName reports whether s looks like an ENS name (anything ending in
// `.eth` for now; a future change could add more TLDs).
func IsENSName(s string) bool {
	s = strings.TrimSpace(strings.ToLower(s))
	return strings.HasSuffix(s, ".eth") && !strings.HasPrefix(s, "0x")
}

// ResolveENS resolves an ENS name like "vitalik.eth" to an address. Returns
// ErrENSNotFound when the name has no resolver / no address record set —
// distinct from network errors so the UI can ignore the former.
//
// ENS lives on Ethereum mainnet only; Sepolia/Holesky have their own
// registries with different deployments. We don't try to be cross-chain
// here — if the user is on a non-mainnet chain, this will simply return
// ErrENSNotFound.
func (c *Client) ResolveENS(ctx context.Context, name string) (Address, error) {
	if !IsENSName(name) {
		return Address{}, fmt.Errorf("ethkit: %q is not an ENS name", name)
	}

	if c.chainID == nil || c.chainID.Int64() != 1 {
		return Address{}, ErrENSNotFound
	}

	resolved, err := goens.Resolve(c.http, strings.ToLower(strings.TrimSpace(name)))
	if err != nil {
		// go-ens returns plain `error` strings — sniff for the "no resolver"
		// / "unregistered" cases and translate to the typed sentinel so the
		// UI can show "no ENS record" instead of red error text.
		msg := err.Error()
		if strings.Contains(msg, "no resolver") ||
			strings.Contains(msg, "no address") ||
			strings.Contains(msg, "unregistered name") ||
			strings.Contains(msg, "not a valid name") {
			return Address{}, ErrENSNotFound
		}
		return Address{}, fmt.Errorf("ethkit: ENS resolve %q: %w", name, err)
	}

	return AddressFromCommon(resolved), nil
}

// ReverseENS looks up the primary ENS name registered for `addr`. Mainnet-
// only; off-chain reverse records aren't supported.
func (c *Client) ReverseENS(ctx context.Context, addr Address) (string, error) {
	if c.chainID == nil || c.chainID.Int64() != 1 {
		return "", ErrENSNotFound
	}

	name, err := goens.ReverseResolve(c.http, addr.Common())
	if err != nil {
		msg := err.Error()
		// go-ens / ENS contracts surface "no record" through several
		// inconsistent strings depending on whether the resolver itself is
		// missing, the name → address mapping is empty, or the reverse
		// record points at a stale resolver. Treat all of them as "no
		// reverse name set" — that's not an error worth surfacing.
		if strings.Contains(msg, "not found") ||
			strings.Contains(msg, "no resolver") ||
			strings.Contains(msg, "not a resolver") ||
			strings.Contains(msg, "no resolution") {
			return "", ErrENSNotFound
		}
		return "", fmt.Errorf("ethkit: ENS reverse %s: %w", addr.Hex(), err)
	}

	return name, nil
}
