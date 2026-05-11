package ethkit

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const sampleAddr = "0x52908400098527886e0f7030069857d2e4169ee7"

func TestNewAddressValid(t *testing.T) {
	a, err := NewAddress(sampleAddr)
	require.NoError(t, err)
	assert.False(t, a.IsZero())
	// Hex output is EIP-55 checksummed.
	assert.True(t, strings.HasPrefix(a.Hex(), "0x"))
}

func TestNewAddressMixedCase(t *testing.T) {
	a, err := NewAddress("0x52908400098527886E0F7030069857D2E4169EE7")
	require.NoError(t, err)
	assert.False(t, a.IsZero())
}

func TestNewAddressMissingPrefix(t *testing.T) {
	// go-ethereum's IsHexAddress accepts both with and without 0x.
	_, err := NewAddress("52908400098527886e0f7030069857d2e4169ee7")
	require.NoError(t, err)
}

func TestNewAddressInvalid(t *testing.T) {
	_, err := NewAddress("not-an-address")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "invalid ethereum address")
}

func TestMustAddressPanics(t *testing.T) {
	require.Panics(t, func() {
		_ = MustAddress("garbage")
	})
	require.NotPanics(t, func() {
		_ = MustAddress(sampleAddr)
	})
}

func TestHexShortString(t *testing.T) {
	a := MustAddress(sampleAddr)
	hex := a.Hex()
	assert.Equal(t, hex, a.String())

	short := a.Short()
	assert.True(t, strings.HasPrefix(short, "0x"))
	assert.Contains(t, short, "...")
}

func TestShortFallback(t *testing.T) {
	// A hand-constructed Address with very short hex should fall through.
	var a Address
	short := a.Short()
	// ZeroAddress.Hex() length is 42 (0x + 40), so this returns the truncated form.
	assert.NotEmpty(t, short)
}

func TestIsZeroAndEqual(t *testing.T) {
	assert.True(t, ZeroAddress.IsZero())

	a := MustAddress(sampleAddr)
	b := MustAddress(strings.ToUpper(sampleAddr))
	assert.True(t, a.Equal(b))
	assert.False(t, a.Equal(ZeroAddress))
}

func TestMarshalUnmarshalJSON(t *testing.T) {
	a := MustAddress(sampleAddr)
	b, err := json.Marshal(a)
	require.NoError(t, err)
	assert.Contains(t, string(b), "0x")

	var got Address
	require.NoError(t, json.Unmarshal(b, &got))
	assert.True(t, got.Equal(a))

	// Bad JSON.
	var bad Address
	require.Error(t, bad.UnmarshalJSON([]byte("not-json")))
	require.Error(t, bad.UnmarshalJSON([]byte(`"not-an-address"`)))
}

func TestMarshalUnmarshalText(t *testing.T) {
	a := MustAddress(sampleAddr)
	b, err := a.MarshalText()
	require.NoError(t, err)
	assert.NotEmpty(t, b)

	var got Address
	require.NoError(t, got.UnmarshalText(b))
	assert.True(t, got.Equal(a))

	var bad Address
	assert.Error(t, bad.UnmarshalText([]byte("not-an-addr")))
}
