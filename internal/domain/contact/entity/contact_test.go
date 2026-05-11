package entity

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

func TestSentinelErrors(t *testing.T) {
	require.NotNil(t, ErrNotFound)
	require.NotNil(t, ErrAlreadyExists)

	assert.Equal(t, liberrors.CodeNotFound, liberrors.GetCode(ErrNotFound))
	assert.Equal(t, liberrors.CodeAlreadyExists, liberrors.GetCode(ErrAlreadyExists))
}

func TestContactStruct(t *testing.T) {
	now := time.Now()
	c := Contact{
		ID:         "id-1",
		Address:    ethkit.ZeroAddress,
		Name:       "Alice",
		Notes:      "friend",
		IsFavorite: true,
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	assert.Equal(t, "id-1", c.ID)
	assert.Equal(t, "Alice", c.Name)
	assert.Equal(t, "friend", c.Notes)
	assert.True(t, c.IsFavorite)
	assert.True(t, c.Address.IsZero())
	assert.Equal(t, now, c.CreatedAt)
	assert.Equal(t, now, c.UpdatedAt)
}
