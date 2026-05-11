package ethkit

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/ethereum/go-ethereum/common"
)

// Address is a type-safe wrapper over common.Address with checksum, display, and validation.
type Address struct {
	raw common.Address
}

// ZeroAddress is the null address 0x0000...0000.
var ZeroAddress = Address{}

// NewAddress parses a hex string into an Address, validating format.
// Accepts both checksummed and lowercase forms.
func NewAddress(hex string) (Address, error) {
	if !common.IsHexAddress(hex) {
		return ZeroAddress, fmt.Errorf("invalid ethereum address: %s", hex)
	}

	return Address{raw: common.HexToAddress(hex)}, nil
}

// MustAddress parses a hex string and panics on invalid input.
// Use only for hardcoded addresses (contract constants, etc.).
func MustAddress(hex string) Address {
	a, err := NewAddress(hex)
	if err != nil {
		panic(err)
	}

	return a
}

// AddressFromCommon wraps a common.Address.
func AddressFromCommon(addr common.Address) Address {
	return Address{raw: addr}
}

// Common returns the underlying common.Address (for go-ethereum APIs).
func (a Address) Common() common.Address {
	return a.raw
}

// Hex returns the EIP-55 checksummed hex string (0x prefixed).
func (a Address) Hex() string {
	return a.raw.Hex()
}

// Short returns a truncated display form: 0x1234...5678.
func (a Address) Short() string {
	h := a.raw.Hex()
	if len(h) < 12 {
		return h
	}

	return h[:6] + "..." + h[len(h)-4:]
}

// String implements Stringer — returns checksummed hex.
func (a Address) String() string {
	return a.Hex()
}

// IsZero reports whether the address is the null address.
func (a Address) IsZero() bool {
	return a.raw == (common.Address{})
}

// Equal reports case-insensitive equality.
func (a Address) Equal(b Address) bool {
	return strings.EqualFold(a.raw.Hex(), b.raw.Hex())
}

// MarshalText implements encoding.TextMarshaler (used by JSON, YAML, etc.).
func (a Address) MarshalText() ([]byte, error) {
	return []byte(a.Hex()), nil
}

// UnmarshalText implements encoding.TextUnmarshaler.
func (a *Address) UnmarshalText(data []byte) error {
	addr, err := NewAddress(string(data))
	if err != nil {
		return err
	}

	*a = addr

	return nil
}

// MarshalJSON marshals as a quoted hex string.
func (a Address) MarshalJSON() ([]byte, error) {
	return json.Marshal(a.Hex())
}

// UnmarshalJSON unmarshals from a quoted hex string.
func (a *Address) UnmarshalJSON(data []byte) error {
	var s string
	if err := json.Unmarshal(data, &s); err != nil {
		return err
	}

	return a.UnmarshalText([]byte(s))
}
