package ethkit

import (
	hdwallet "github.com/miguelmota/go-ethereum-hdwallet"
	"github.com/tyler-smith/go-bip39"
)

// DefaultDerivationPath is the standard Ethereum BIP44 path (account 0, index 0).
const DefaultDerivationPath = "m/44'/60'/0'/0/0"

// GenerateMnemonic generates a new random 12-word BIP39 mnemonic.
func GenerateMnemonic() (string, error) {
	entropy, err := bip39.NewEntropy(128) // 128 bits → 12 words
	if err != nil {
		return "", err
	}

	return bip39.NewMnemonic(entropy)
}

// NewWalletFromMnemonic derives a wallet from a BIP39 mnemonic using the given
// derivation path. Pass DefaultDerivationPath for the standard Ethereum account.
func NewWalletFromMnemonic(mnemonic, derivationPath string) (*Wallet, error) {
	if derivationPath == "" {
		derivationPath = DefaultDerivationPath
	}

	w, err := hdwallet.NewFromMnemonic(mnemonic)
	if err != nil {
		return nil, err
	}
	// `w` holds the derived seed inside an opened hdwallet handle — close it
	// on every exit path so the underlying byte buffer is zeroed rather than
	// left dangling for the GC.
	defer func() { _ = w.Close() }()

	path, err := hdwallet.ParseDerivationPath(derivationPath)
	if err != nil {
		return nil, err
	}

	account, err := w.Derive(path, false)
	if err != nil {
		return nil, err
	}

	pk, err := w.PrivateKey(account)
	if err != nil {
		return nil, err
	}

	return newWalletFromECDSA(pk)
}

// ValidateMnemonic reports whether mnemonic is a valid BIP39 phrase.
func ValidateMnemonic(mnemonic string) bool {
	return bip39.IsMnemonicValid(mnemonic)
}
