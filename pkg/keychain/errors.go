package keychain

import "errors"

// ErrNotFound is returned when no entry exists for the given key.
var ErrNotFound = errors.New("keychain: entry not found")
