package ethkit

import (
	"fmt"
	"math/big"

	"github.com/shopspring/decimal"
)

var (
	weiPerEth  = decimal.NewFromInt(1e18)
	weiPerGwei = decimal.NewFromInt(1e9)
)

// Amount represents a token/ETH value stored internally in Wei.
// All arithmetic is exact — no floating point.
type Amount struct {
	wei *big.Int
}

// ZeroAmount is a zero-value Amount.
var ZeroAmount = Amount{wei: new(big.Int)}

// NewAmountFromWei creates an Amount from a Wei *big.Int.
// The value is copied, so the caller can safely reuse the original.
func NewAmountFromWei(wei *big.Int) Amount {
	if wei == nil {
		return ZeroAmount
	}

	return Amount{wei: new(big.Int).Set(wei)}
}

// NewAmountFromETH creates an Amount from an ETH decimal value (e.g. "1.5").
func NewAmountFromETH(eth decimal.Decimal) Amount {
	wei := eth.Mul(weiPerEth).BigInt()
	return Amount{wei: wei}
}

// NewAmountFromGwei creates an Amount from a Gwei decimal value.
func NewAmountFromGwei(gwei decimal.Decimal) Amount {
	wei := gwei.Mul(weiPerGwei).BigInt()
	return Amount{wei: wei}
}

// NewAmountFromTokenUnits creates an Amount from human-readable token units
// (e.g. "100.5" USDC with 6 decimals).
func NewAmountFromTokenUnits(units decimal.Decimal, decimals uint8) Amount {
	multiplier := decimal.New(1, int32(decimals))
	wei := units.Mul(multiplier).BigInt()

	return Amount{wei: wei}
}

// Wei returns a copy of the underlying big.Int in Wei.
func (a Amount) Wei() *big.Int {
	if a.wei == nil {
		return new(big.Int)
	}

	return new(big.Int).Set(a.wei)
}

// ToETH returns the value in ETH as a decimal.
func (a Amount) ToETH() decimal.Decimal {
	return decimal.NewFromBigInt(a.safe(), 0).Div(weiPerEth)
}

// ToGwei returns the value in Gwei as a decimal.
func (a Amount) ToGwei() decimal.Decimal {
	return decimal.NewFromBigInt(a.safe(), 0).Div(weiPerGwei)
}

// ToTokenUnits returns the value in human-readable token units for a token with the given decimals.
func (a Amount) ToTokenUnits(decimals uint8) decimal.Decimal {
	divisor := decimal.New(1, int32(decimals))
	return decimal.NewFromBigInt(a.safe(), 0).Div(divisor)
}

// FormatETH returns the ETH value as a string with the given decimal places.
func (a Amount) FormatETH(places int32) string {
	return a.ToETH().StringFixed(places) + " ETH"
}

// FormatGwei returns the Gwei value as a string with 2 decimal places.
func (a Amount) FormatGwei() string {
	return a.ToGwei().StringFixed(2) + " Gwei"
}

// FormatToken returns the token value as a string with the given decimal places.
func (a Amount) FormatToken(places int32, symbol string) string {
	return a.ToTokenUnits(uint8(places)).StringFixed(places) + " " + symbol
}

// String returns the ETH value with 6 decimal places.
func (a Amount) String() string {
	return a.ToETH().StringFixed(6) + " ETH"
}

// IsZero reports whether the amount is zero.
func (a Amount) IsZero() bool {
	return a.safe().Sign() == 0
}

// IsNegative reports whether the amount is negative.
func (a Amount) IsNegative() bool {
	return a.safe().Sign() < 0
}

// Add returns a + b.
func (a Amount) Add(b Amount) Amount {
	return Amount{wei: new(big.Int).Add(a.safe(), b.safe())}
}

// Sub returns a - b.
func (a Amount) Sub(b Amount) Amount {
	return Amount{wei: new(big.Int).Sub(a.safe(), b.safe())}
}

// MulInt returns a * n.
func (a Amount) MulInt(n int64) Amount {
	return Amount{wei: new(big.Int).Mul(a.safe(), big.NewInt(n))}
}

// Cmp compares two amounts: returns -1 if a < b, 0 if equal, 1 if a > b.
func (a Amount) Cmp(b Amount) int {
	return a.safe().Cmp(b.safe())
}

// GT returns a > b.
func (a Amount) GT(b Amount) bool { return a.Cmp(b) > 0 }

// LT returns a < b.
func (a Amount) LT(b Amount) bool { return a.Cmp(b) < 0 }

// GTE returns a >= b.
func (a Amount) GTE(b Amount) bool { return a.Cmp(b) >= 0 }

// LTE returns a <= b.
func (a Amount) LTE(b Amount) bool { return a.Cmp(b) <= 0 }

// Equal returns a == b.
func (a Amount) Equal(b Amount) bool { return a.Cmp(b) == 0 }

// MarshalText implements encoding.TextMarshaler — serializes as Wei decimal string.
func (a Amount) MarshalText() ([]byte, error) {
	return []byte(a.safe().String()), nil
}

// UnmarshalText implements encoding.TextUnmarshaler — parses a Wei decimal string.
func (a *Amount) UnmarshalText(data []byte) error {
	n := new(big.Int)
	if _, ok := n.SetString(string(data), 10); !ok {
		return fmt.Errorf("invalid wei amount: %s", data)
	}

	a.wei = n

	return nil
}

func (a Amount) safe() *big.Int {
	if a.wei == nil {
		return new(big.Int)
	}

	return a.wei
}
