package entity

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
)

func TestWalletSentinelErrors(t *testing.T) {
	require.NotNil(t, ErrNotFound)
	assert.Equal(t, liberrors.CodeNotFound, liberrors.GetCode(ErrNotFound))
}

func TestSecretTypeConstants(t *testing.T) {
	assert.Equal(t, SecretTypeMnemonic, SecretType("mnemonic"))
	assert.Equal(t, SecretTypePrivateKey, SecretType("privatekey"))
}

func TestWalletStruct(t *testing.T) {
	w := Wallet{ID: "x", Label: "main", SecretType: SecretTypeMnemonic}
	assert.Equal(t, "x", w.ID)
	assert.Equal(t, "main", w.Label)
	assert.Equal(t, SecretTypeMnemonic, w.SecretType)
}
