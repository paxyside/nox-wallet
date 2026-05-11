package entity

import "github.com/paxyside/nox-wallet/pkg/errors"

var (
	ErrNotFound      = errors.New(errors.CodeNotFound, "contact not found")
	ErrAlreadyExists = errors.New(errors.CodeAlreadyExists, "contact with this address already exists")
)
