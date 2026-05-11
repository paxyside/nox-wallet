package entity

import (
	"time"

	"github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// SecretType describes how the wallet secret is stored in keychain.
type SecretType string

const (
	SecretTypeMnemonic   SecretType = "mnemonic"
	SecretTypePrivateKey SecretType = "privatekey"
)

type Wallet struct {
	ID         string
	Address    ethkit.Address
	Label      string
	SecretType SecretType
	CreatedAt  time.Time
}

var ErrNotFound = errors.New(errors.CodeNotFound, "wallet not found")
