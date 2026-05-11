package ethkit

import (
	"crypto/ecdsa"
	"encoding/hex"
	"errors"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
)

// Wallet holds a private key and exposes signing operations.
// It never exposes the raw private key bytes after construction.
type Wallet struct {
	privateKey *ecdsa.PrivateKey
	address    Address
}

// NewWalletFromHex loads a wallet from a hex-encoded private key string.
// Accepts both "0x"-prefixed and bare hex.
func NewWalletFromHex(hexKey string) (*Wallet, error) {
	hexKey = strings.TrimPrefix(hexKey, "0x")

	b, err := hex.DecodeString(hexKey)
	if err != nil {
		return nil, fmt.Errorf("ethkit: invalid private key hex: %w", err)
	}

	return newWalletFromBytes(b)
}

// NewWalletFromKeystore decrypts a geth-format keystore JSON file.
func NewWalletFromKeystore(keystoreJSON []byte, passphrase string) (*Wallet, error) {
	key, err := keystore.DecryptKey(keystoreJSON, passphrase)
	if err != nil {
		return nil, fmt.Errorf("ethkit: keystore decrypt: %w", err)
	}

	return newWalletFromECDSA(key.PrivateKey)
}

func newWalletFromBytes(b []byte) (*Wallet, error) {
	pk, err := crypto.ToECDSA(b)
	if err != nil {
		return nil, fmt.Errorf("ethkit: invalid private key: %w", err)
	}

	return newWalletFromECDSA(pk)
}

func newWalletFromECDSA(pk *ecdsa.PrivateKey) (*Wallet, error) {
	pub, ok := pk.Public().(*ecdsa.PublicKey)
	if !ok {
		return nil, errors.New("ethkit: cannot derive public key")
	}

	return &Wallet{
		privateKey: pk,
		address:    AddressFromCommon(crypto.PubkeyToAddress(*pub)),
	}, nil
}

// Address returns the wallet's Ethereum address.
func (w *Wallet) Address() Address {
	return w.address
}

// PrivateKeyHex returns the private key as a hex string (without 0x prefix).
// Used internally when storing to keychain after keystore import.
func (w *Wallet) PrivateKeyHex() string {
	return hex.EncodeToString(crypto.FromECDSA(w.privateKey))
}

// SignTx signs a transaction with EIP-155 replay protection for the given chain ID.
func (w *Wallet) SignTx(tx *types.Transaction, chainID *big.Int) (*types.Transaction, error) {
	signer := types.NewLondonSigner(chainID)

	signed, err := types.SignTx(tx, signer, w.privateKey)
	if err != nil {
		return nil, fmt.Errorf("ethkit: sign tx: %w", err)
	}

	return signed, nil
}

// SignMessage signs an arbitrary message using EIP-191 personal_sign format.
// The returned bytes are the 65-byte [R || S || V] signature.
func (w *Wallet) SignMessage(message []byte) ([]byte, error) {
	// EIP-191: prefix message with "\x19Ethereum Signed Message:\n<len>"
	prefixed := crypto.Keccak256([]byte(fmt.Sprintf("\x19Ethereum Signed Message:\n%d%s", len(message), message)))

	sig, err := crypto.Sign(prefixed, w.privateKey)
	if err != nil {
		return nil, fmt.Errorf("ethkit: sign message: %w", err)
	}
	// Adjust V from 0/1 to 27/28 per personal_sign spec.
	sig[64] += 27

	return sig, nil
}

// SignHash signs a pre-computed 32-byte hash directly (no EIP-191 prefix).
// Use for smart contract interactions that verify raw hashes.
func (w *Wallet) SignHash(hash []byte) ([]byte, error) {
	if len(hash) != 32 {
		return nil, fmt.Errorf("ethkit: hash must be 32 bytes, got %d", len(hash))
	}

	return crypto.Sign(hash, w.privateKey)
}

// ExportKeystore encrypts the private key into a geth keystore JSON blob (no file written).
func (w *Wallet) ExportKeystore(passphrase string) ([]byte, error) {
	key := &keystore.Key{
		Address:    w.address.Common(),
		PrivateKey: w.privateKey,
	}

	b, err := keystore.EncryptKey(key, passphrase, keystore.StandardScryptN, keystore.StandardScryptP)
	if err != nil {
		return nil, fmt.Errorf("ethkit: keystore export: %w", err)
	}

	return b, nil
}
