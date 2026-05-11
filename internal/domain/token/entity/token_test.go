package entity

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
)

func TestTokenSentinelErrors(t *testing.T) {
	require.NotNil(t, ErrNotFound)
	require.NotNil(t, ErrAlreadyExists)

	assert.Equal(t, liberrors.CodeNotFound, liberrors.GetCode(ErrNotFound))
	assert.Equal(t, liberrors.CodeAlreadyExists, liberrors.GetCode(ErrAlreadyExists))
}

func TestWatchedTokenStruct(t *testing.T) {
	wt := WatchedToken{ID: "id"}
	assert.Equal(t, "id", wt.ID)
}
