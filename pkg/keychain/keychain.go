// Package keychain provides secure credential storage via the OS keychain.
// On macOS uses Apple Keychain; cross-platform via go-keyring.
package keychain

import (
	"errors"

	"github.com/zalando/go-keyring"
)

const defaultService = "nox-wallet"

// Client stores and retrieves secrets from the OS keychain.
type Client struct {
	service string
}

// New creates a Client scoped to the given service name. The app
// passes `cfg.App.Name` ("nox-wallet") so the keychain entry matches
// the value `task clean` searches under.
func New(service string) *Client {
	if service == "" {
		service = defaultService
	}

	return &Client{service: service}
}

// Set stores secret under key. Overwrites any existing value.
func (c *Client) Set(key, secret string) error {
	return keyring.Set(c.service, key, secret)
}

// Get retrieves the secret stored under key.
// Returns ErrNotFound if no entry exists.
func (c *Client) Get(key string) (string, error) {
	secret, err := keyring.Get(c.service, key)
	if errors.Is(err, keyring.ErrNotFound) {
		return "", ErrNotFound
	}

	return secret, err
}

// Delete removes the secret stored under key.
// Returns nil if the key does not exist.
func (c *Client) Delete(key string) error {
	err := keyring.Delete(c.service, key)
	if errors.Is(err, keyring.ErrNotFound) {
		return nil
	}

	return err
}
