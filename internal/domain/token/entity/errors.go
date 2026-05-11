package entity

import "github.com/paxyside/nox-wallet/pkg/errors"

var (
	ErrNotFound      = errors.New(errors.CodeNotFound, "token not found")
	ErrAlreadyExists = errors.New(errors.CodeAlreadyExists, "token already watched")
)
