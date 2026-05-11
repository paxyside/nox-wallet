package ethkit

import (
	"math/big"
	"testing"

	"github.com/shopspring/decimal"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewAmountFromWei(t *testing.T) {
	t.Run("nil", func(t *testing.T) {
		a := NewAmountFromWei(nil)
		assert.True(t, a.IsZero())
	})
	t.Run("zero", func(t *testing.T) {
		a := NewAmountFromWei(big.NewInt(0))
		assert.True(t, a.IsZero())
	})
	t.Run("one", func(t *testing.T) {
		a := NewAmountFromWei(big.NewInt(1))
		assert.False(t, a.IsZero())
		assert.Equal(t, "1", a.Wei().String())
	})
	t.Run("copies input", func(t *testing.T) {
		src := big.NewInt(123)
		a := NewAmountFromWei(src)
		src.SetInt64(999)
		assert.Equal(t, "123", a.Wei().String())
	})
}

func TestNewAmountFromETH(t *testing.T) {
	a := NewAmountFromETH(decimal.NewFromInt(1))
	assert.Equal(t, "1000000000000000000", a.Wei().String())

	half := NewAmountFromETH(decimal.NewFromFloat(1.5))
	assert.Equal(t, "1500000000000000000", half.Wei().String())

	zero := NewAmountFromETH(decimal.Zero)
	assert.True(t, zero.IsZero())
}

func TestNewAmountFromGwei(t *testing.T) {
	a := NewAmountFromGwei(decimal.NewFromInt(1))
	assert.Equal(t, "1000000000", a.Wei().String())
}

func TestNewAmountFromTokenUnits(t *testing.T) {
	a := NewAmountFromTokenUnits(decimal.NewFromFloat(100.5), 6)
	assert.Equal(t, "100500000", a.Wei().String())
}

func TestToConversionsRoundTrip(t *testing.T) {
	cases := []struct {
		eth string
	}{
		{"0"}, {"1"}, {"1.5"}, {"0.000000000000001"}, {"123456789.987654321"},
	}
	for _, c := range cases {
		t.Run(c.eth, func(t *testing.T) {
			d, err := decimal.NewFromString(c.eth)
			require.NoError(t, err)
			a := NewAmountFromETH(d)
			// Round-trip via ToETH.
			assert.True(t, a.ToETH().Equal(d), "ETH round-trip for %s got %s", c.eth, a.ToETH().String())
		})
	}
}

func TestToTokenUnitsRoundTrip(t *testing.T) {
	d := decimal.NewFromFloat(100.5)
	a := NewAmountFromTokenUnits(d, 6)
	assert.True(t, a.ToTokenUnits(6).Equal(d))
}

func TestToGweiRoundTrip(t *testing.T) {
	a := NewAmountFromGwei(decimal.NewFromInt(42))
	assert.True(t, a.ToGwei().Equal(decimal.NewFromInt(42)))
}

func TestArithmetic(t *testing.T) {
	one := NewAmountFromWei(big.NewInt(1))
	two := NewAmountFromWei(big.NewInt(2))
	three := one.Add(two)
	assert.Equal(t, "3", three.Wei().String())

	diff := three.Sub(one)
	assert.Equal(t, "2", diff.Wei().String())

	mul := two.MulInt(5)
	assert.Equal(t, "10", mul.Wei().String())
}

func TestComparisons(t *testing.T) {
	a := NewAmountFromWei(big.NewInt(10))
	b := NewAmountFromWei(big.NewInt(20))

	assert.Equal(t, -1, a.Cmp(b))
	assert.Equal(t, 1, b.Cmp(a))
	assert.Equal(t, 0, a.Cmp(NewAmountFromWei(big.NewInt(10))))

	assert.True(t, a.LT(b))
	assert.True(t, a.LTE(b))
	assert.False(t, a.GT(b))
	assert.False(t, a.GTE(b))
	assert.True(t, b.GT(a))
	assert.True(t, b.GTE(a))

	assert.True(t, a.Equal(NewAmountFromWei(big.NewInt(10))))

	zero := Amount{}
	assert.True(t, zero.IsZero())
	neg := NewAmountFromWei(big.NewInt(-1))
	assert.True(t, neg.IsNegative())
	assert.False(t, NewAmountFromWei(big.NewInt(1)).IsNegative())
}

func TestAmountMarshalUnmarshalText(t *testing.T) {
	a := NewAmountFromWei(big.NewInt(123456789))
	b, err := a.MarshalText()
	require.NoError(t, err)
	assert.Equal(t, "123456789", string(b))

	var got Amount
	require.NoError(t, got.UnmarshalText(b))
	assert.True(t, got.Equal(a))

	var bad Amount
	assert.Error(t, bad.UnmarshalText([]byte("not-a-number")))
}

func TestSafeWithNilInternal(t *testing.T) {
	// Zero-value Amount has a nil internal big.Int — operations should not panic.
	var a Amount
	assert.True(t, a.IsZero())
	assert.False(t, a.IsNegative())
	assert.Equal(t, "0", a.Wei().String())
	assert.Equal(t, "0", a.ToETH().String())
	assert.Equal(t, "0", a.ToGwei().String())
}

func TestStringAndFormatters(t *testing.T) {
	a := NewAmountFromETH(decimal.NewFromFloat(1.5))
	assert.Contains(t, a.String(), "ETH")
	assert.Contains(t, a.FormatETH(2), "1.50 ETH")
	assert.Contains(t, a.FormatGwei(), "Gwei")
	assert.Contains(t, NewAmountFromTokenUnits(decimal.NewFromInt(100), 6).FormatToken(6, "USDC"), "USDC")
}

func TestMaxUint256(t *testing.T) {
	maxVal := new(big.Int).Lsh(big.NewInt(1), 256)
	maxVal.Sub(maxVal, big.NewInt(1))

	a := NewAmountFromWei(maxVal)
	assert.Equal(t, maxVal.String(), a.Wei().String())
	assert.False(t, a.IsZero())
	assert.False(t, a.IsNegative())
}
