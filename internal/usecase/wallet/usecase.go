package wallet

import (
	"context"
	"math/big"

	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	walletservice "github.com/paxyside/nox-wallet/internal/domain/wallet/service"
	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/keychain"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

const keychainKey = "wallet_secret"

// EthClient is the subset of ethkit.Client operations this usecase needs.
type EthClient interface {
	ETHBalance(ctx context.Context, addr ethkit.Address) (ethkit.Amount, error)
	TokenBalance(ctx context.Context, addr ethkit.Address, token ethkit.Token) (ethkit.Amount, error)
	GasFees(ctx context.Context) (ethkit.GasInfo, error)
	BlockNumber(ctx context.Context) (uint64, error)
	ChainID() *big.Int
	ResolveENS(ctx context.Context, name string) (ethkit.Address, error)
	ReverseENS(ctx context.Context, addr ethkit.Address) (string, error)
	SpeedUpTx(ctx context.Context, w *ethkit.Wallet, hash string) (string, error)
	CancelTx(ctx context.Context, w *ethkit.Wallet, hash string) (string, error)
	SimulateTx(ctx context.Context, sender ethkit.Address, req ethkit.TxRequest) (ethkit.SimulationResult, error)
	PendingForAddress(addr ethkit.Address) []ethkit.PendingTx
	GasEstimateWithFees(
		ctx context.Context,
		req ethkit.TxRequest,
		sender ethkit.Address,
	) (uint64, ethkit.GasInfo, ethkit.Amount, error)
	SendTx(ctx context.Context, w *ethkit.Wallet, req ethkit.TxRequest) (ethkit.TxReceipt, error)
	TransferToken(
		ctx context.Context,
		w *ethkit.Wallet,
		token ethkit.Token,
		to ethkit.Address,
		amount ethkit.Amount,
	) (ethkit.TxReceipt, error)
	TransferTokenWithGas(
		ctx context.Context,
		w *ethkit.Wallet,
		token ethkit.Token,
		to ethkit.Address,
		amount ethkit.Amount,
		gasTip *ethkit.Amount,
		gasCap *ethkit.Amount,
	) (ethkit.TxReceipt, error)
	TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
}

// WalletService is the domain service interface.
type WalletService interface {
	Save(ctx context.Context, w *entity.Wallet) error
	Get(ctx context.Context) (*entity.Wallet, error)
	Delete(ctx context.Context) error
}

var _ WalletService = (*walletservice.Service)(nil)

type Usecase struct {
	*usecase.BaseUsecase
	log      logger.Log
	eth      EthClient
	svc      WalletService
	keychain *keychain.Client
	wallet   *ethkit.Wallet // loaded in-memory
}

func New(base *usecase.BaseUsecase, log logger.Log, eth EthClient, svc WalletService, kc *keychain.Client) *Usecase {
	return &Usecase{BaseUsecase: base, log: log, eth: eth, svc: svc, keychain: kc}
}

// ── wallet loading ────────────────────────────────────────────────────────────

// LoadFromKeychain tries to restore the wallet from keychain on startup.
// Returns nil error if no wallet is stored yet.
func (u *Usecase) LoadFromKeychain(ctx context.Context) error {
	record, err := u.svc.Get(ctx)
	if liberrors.Is(err, entity.ErrNotFound) {
		return nil
	}

	if err != nil {
		return err
	}

	secret, err := u.keychain.Get(keychainKey)
	if liberrors.Is(err, keychain.ErrNotFound) {
		u.log.WarnContext(ctx, "wallet record found but keychain secret missing",
			"address", record.Address.Short())
		return nil
	}

	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "read keychain")
	}

	switch record.SecretType {
	case entity.SecretTypeMnemonic:
		w, err := ethkit.NewWalletFromMnemonic(secret, ethkit.DefaultDerivationPath)
		if err != nil {
			return liberrors.Wrapf(err, liberrors.CodeInternal, "restore wallet from mnemonic")
		}

		u.wallet = w
	case entity.SecretTypePrivateKey:
		w, err := ethkit.NewWalletFromHex(secret)
		if err != nil {
			return liberrors.Wrapf(err, liberrors.CodeInternal, "restore wallet from private key")
		}

		u.wallet = w
	default:
		return liberrors.Newf(liberrors.CodeInternal, "unknown secret type %q", record.SecretType)
	}

	u.log.InfoContext(ctx, "wallet loaded from keychain", "address", record.Address.Short())

	return nil
}

// ── import / generate ─────────────────────────────────────────────────────────

// GenerateWallet creates a brand-new wallet from a random 12-word mnemonic.
// Returns the mnemonic — caller must display it once and not store it anywhere else.
func (u *Usecase) GenerateWallet(ctx context.Context, p GenerateWalletParams) (GenerateWalletResult, error) {
	mnemonic, err := ethkit.GenerateMnemonic()
	if err != nil {
		return GenerateWalletResult{}, liberrors.Wrapf(err, liberrors.CodeInternal, "generate mnemonic")
	}

	record, err := u.importAndPersist(ctx, mnemonic, entity.SecretTypeMnemonic, p.Label)
	if err != nil {
		return GenerateWalletResult{}, err
	}

	return GenerateWalletResult{Address: record.Address, Mnemonic: mnemonic}, nil
}

// ImportMnemonic restores a wallet from an existing BIP39 mnemonic.
func (u *Usecase) ImportMnemonic(ctx context.Context, p ImportMnemonicParams) (*entity.Wallet, error) {
	if !ethkit.ValidateMnemonic(p.Mnemonic) {
		return nil, liberrors.New(liberrors.CodeInvalidArgument, "invalid mnemonic phrase")
	}

	path := p.DerivationPath
	if path == "" {
		path = ethkit.DefaultDerivationPath
	}

	w, err := ethkit.NewWalletFromMnemonic(p.Mnemonic, path)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "derive wallet from mnemonic")
	}

	return u.persistWallet(ctx, w, p.Mnemonic, entity.SecretTypeMnemonic, p.Label)
}

// ImportPrivateKey imports a wallet from a raw hex private key.
func (u *Usecase) ImportPrivateKey(ctx context.Context, p ImportPrivateKeyParams) (*entity.Wallet, error) {
	w, err := ethkit.NewWalletFromHex(p.PrivateKeyHex)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid private key")
	}

	return u.persistWallet(ctx, w, p.PrivateKeyHex, entity.SecretTypePrivateKey, p.Label)
}

// ImportKeystore imports a wallet from an encrypted Ethereum keystore JSON file.
func (u *Usecase) ImportKeystore(ctx context.Context, p ImportKeystoreParams) (*entity.Wallet, error) {
	w, err := ethkit.NewWalletFromKeystore(p.KeystoreJSON, p.Passphrase)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "decrypt keystore")
	}
	// Store the private key hex so we can restore without the keystore file.
	hexKey := w.PrivateKeyHex()

	return u.persistWallet(ctx, w, hexKey, entity.SecretTypePrivateKey, p.Label)
}

// ── reveal ────────────────────────────────────────────────────────────────────

// RevealSecret returns the raw mnemonic or private key stored in the keychain.
func (u *Usecase) RevealSecret(ctx context.Context) (RevealSecretResult, error) {
	secret, err := u.keychain.Get(keychainKey)
	if err != nil {
		return RevealSecretResult{}, liberrors.Wrapf(err, liberrors.CodeInternal, "read keychain")
	}

	record, err := u.svc.Get(ctx)
	if err != nil {
		return RevealSecretResult{}, err
	}

	return RevealSecretResult{Secret: secret, SecretType: record.SecretType}, nil
}

// ── export ────────────────────────────────────────────────────────────────────

// ExportKeystore encrypts the loaded wallet with passphrase and returns the JSON keystore bytes.
func (u *Usecase) ExportKeystore(p ExportKeystoreParams) ([]byte, error) {
	if u.wallet == nil {
		return nil, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	data, err := u.wallet.ExportKeystore(p.Passphrase)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "export keystore")
	}

	return data, nil
}

// ── read ──────────────────────────────────────────────────────────────────────

func (u *Usecase) GetWallet(ctx context.Context) (*entity.Wallet, error) {
	return u.svc.Get(ctx)
}

func (u *Usecase) GetBalances(ctx context.Context, p GetBalancesParams) (GetBalancesResult, error) {
	eth, err := u.eth.ETHBalance(ctx, p.Address)
	if err != nil {
		return GetBalancesResult{}, liberrors.Wrapf(err, liberrors.CodeInternal, "eth balance")
	}

	result := GetBalancesResult{ETH: eth}
	for _, token := range p.Tokens {
		bal, err := u.eth.TokenBalance(ctx, p.Address, token)
		if err != nil {
			u.log.WarnContext(ctx, "token balance failed", "token", token.Symbol, "error", err)
			continue
		}

		result.Tokens = append(result.Tokens, TokenBalance{Token: token, Balance: bal})
	}

	return result, nil
}

func (u *Usecase) GetGasFees(ctx context.Context) (GetGasFeesResult, error) {
	type gasResult struct {
		info ethkit.GasInfo
		err  error
	}

	type blockResult struct {
		num uint64
		err error
	}

	gasCh := make(chan gasResult, 1)
	blockCh := make(chan blockResult, 1)

	go func() {
		info, err := u.eth.GasFees(ctx)
		gasCh <- gasResult{info, err}
	}()
	go func() {
		n, err := u.eth.BlockNumber(ctx)
		blockCh <- blockResult{n, err}
	}()

	gr := <-gasCh
	if gr.err != nil {
		return GetGasFeesResult{}, liberrors.Wrapf(gr.err, liberrors.CodeInternal, "gas fees")
	}

	br := <-blockCh
	if br.err != nil {
		return GetGasFeesResult{}, liberrors.Wrapf(br.err, liberrors.CodeInternal, "block number")
	}

	chainID := int64(0)
	if id := u.eth.ChainID(); id != nil {
		chainID = id.Int64()
	}

	return GetGasFeesResult{
		GasInfo:     gr.info,
		TransferETH: gr.info.EstimatedCost(21_000),
		BlockNumber: br.num,
		ChainID:     chainID,
	}, nil
}

// ── ENS ──────────────────────────────────────────────────────────────────────

// ResolveENS turns "vitalik.eth" into an address. Returns ErrNotFound (well,
// CodeNotFound) when the name resolves to nothing — clients should treat
// that as "no record set" rather than as an error to surface.
func (u *Usecase) ResolveENS(ctx context.Context, name string) (ethkit.Address, error) {
	addr, err := u.eth.ResolveENS(ctx, name)
	if err != nil {
		if liberrors.Is(err, ethkit.ErrENSNotFound) {
			return ethkit.Address{}, liberrors.New(liberrors.CodeNotFound, "ENS name not found")
		}
		return ethkit.Address{}, liberrors.Wrapf(err, liberrors.CodeInternal, "resolve ENS")
	}
	return addr, nil
}

// ReverseENS looks up the primary name registered for `addr` (if any).
func (u *Usecase) ReverseENS(ctx context.Context, addr ethkit.Address) (string, error) {
	name, err := u.eth.ReverseENS(ctx, addr)
	if err != nil {
		if liberrors.Is(err, ethkit.ErrENSNotFound) {
			return "", liberrors.New(liberrors.CodeNotFound, "no ENS record")
		}
		return "", liberrors.Wrapf(err, liberrors.CodeInternal, "reverse ENS")
	}
	return name, nil
}

// ── Tx simulation ─────────────────────────────────────────────────────────────

// SimulateSendETH dry-runs to send via eth_call so the UI can preview
// success / revert + gas cost before the user confirms. Wallet must be
// loaded; addresses are validated by the caller.
func (u *Usecase) SimulateSendETH(
	ctx context.Context,
	to ethkit.Address,
	value ethkit.Amount,
) (ethkit.SimulationResult, error) {
	if u.wallet == nil {
		return ethkit.SimulationResult{}, liberrors.New(
			liberrors.CodeFailedPrecondition, "no wallet loaded")
	}
	return u.eth.SimulateTx(ctx, u.wallet.Address(), ethkit.TxRequest{
		To:    to,
		Value: value,
	})
}

// SimulateSendToken dry-runs an ERC-20 transfer. The amount is in token
// units — we resolve the token's decimals before packing the call.
func (u *Usecase) SimulateSendToken(
	ctx context.Context,
	tokenAddr ethkit.Address,
	to ethkit.Address,
	amount decimal.Decimal,
) (ethkit.SimulationResult, error) {
	if u.wallet == nil {
		return ethkit.SimulationResult{}, liberrors.New(
			liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	token, err := u.eth.TokenMetadata(ctx, tokenAddr)
	if err != nil {
		return ethkit.SimulationResult{}, liberrors.Wrapf(
			err, liberrors.CodeInternal, "token metadata")
	}

	wei := ethkit.NewAmountFromTokenUnits(amount, token.Decimals)
	data, err := ethkit.PackERC20Transfer(to, wei)
	if err != nil {
		return ethkit.SimulationResult{}, liberrors.Wrapf(
			err, liberrors.CodeInternal, "pack erc20 transfer")
	}

	return u.eth.SimulateTx(ctx, u.wallet.Address(), ethkit.TxRequest{
		To:   token.Address,
		Data: data,
	})
}

// ── Pending transactions ─────────────────────────────────────────────────────

// ListPending returns the in-flight (broadcast-but-not-mined) transactions
// for the loaded wallet. Empty when no wallet is loaded — callers should
// treat that as a normal empty state.
func (u *Usecase) ListPending() []ethkit.PendingTx {
	if u.wallet == nil {
		return nil
	}
	return u.eth.PendingForAddress(u.wallet.Address())
}

// ── Replacement transactions ─────────────────────────────────────────────────

// SpeedUpTx asks the chain to mine a higher-gas replacement of the given
// pending transaction. Returns the new transaction hash.
func (u *Usecase) SpeedUpTx(ctx context.Context, hash string) (string, error) {
	if u.wallet == nil {
		return "", liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}
	newHash, err := u.eth.SpeedUpTx(ctx, u.wallet, hash)
	if err != nil {
		return "", liberrors.Wrapf(err, liberrors.CodeInternal, "speed up tx")
	}
	return newHash, nil
}

// CancelTx submits a self-transfer at the original nonce with bumped gas.
// Best-effort: if the original tx mines first, the cancel is just a wasted
// self-transfer fee.
func (u *Usecase) CancelTx(ctx context.Context, hash string) (string, error) {
	if u.wallet == nil {
		return "", liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}
	newHash, err := u.eth.CancelTx(ctx, u.wallet, hash)
	if err != nil {
		return "", liberrors.Wrapf(err, liberrors.CodeInternal, "cancel tx")
	}
	return newHash, nil
}

// ── send ──────────────────────────────────────────────────────────────────────

func (u *Usecase) SendETH(ctx context.Context, p SendETHParams) (ethkit.TxReceipt, error) {
	if u.wallet == nil {
		return ethkit.TxReceipt{}, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	tip, gasCap := gasOverrideToAmounts(p.Gas)
	return u.eth.SendTx(ctx, u.wallet, ethkit.TxRequest{
		To:     p.To,
		Value:  p.Value,
		GasTip: tip,
		GasCap: gasCap,
		Kind:   "send",
	})
}

func (u *Usecase) SendToken(ctx context.Context, p SendTokenParams) (ethkit.TxReceipt, error) {
	if u.wallet == nil {
		return ethkit.TxReceipt{}, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	// Resolve on-chain metadata so we know the token's decimals — without this
	// a "100" entry would be packed as 100·10¹⁸ wei (interpreting amount as ETH)
	// and a 6-decimal token like USDC would receive 10¹⁴ tokens.
	token, err := u.eth.TokenMetadata(ctx, p.TokenAddress)
	if err != nil {
		return ethkit.TxReceipt{}, liberrors.Wrapf(err, liberrors.CodeInternal, "token metadata")
	}

	amount := ethkit.NewAmountFromTokenUnits(p.Amount, token.Decimals)

	tip, gasCap := gasOverrideToAmounts(p.Gas)
	return u.eth.TransferTokenWithGas(ctx, u.wallet, token, p.To, amount, tip, gasCap)
}

// gasOverrideToAmounts converts the human-friendly GasOverride struct into
// ethkit.Amount values (wei) suitable for TxRequest. Returns (nil, nil)
// when no overrides are set so the network suggestion stays in effect.
func gasOverrideToAmounts(g GasOverride) (*ethkit.Amount, *ethkit.Amount) {
	var tip, gasCap *ethkit.Amount
	if g.PriorityGwei != nil {
		tip = new(ethkit.NewAmountFromGwei(*g.PriorityGwei))
	}
	if g.MaxGwei != nil {
		gasCap = new(ethkit.NewAmountFromGwei(*g.MaxGwei))
	}
	return tip, gasCap
}

func (u *Usecase) LoadedAddress() ethkit.Address {
	if u.wallet == nil {
		return ethkit.ZeroAddress
	}

	return u.wallet.Address()
}

// EthWallet returns the loaded signing wallet, or nil if none is loaded.
// This is the single source of truth — all signing usecases should pull from here
// rather than holding their own copy.
func (u *Usecase) EthWallet() *ethkit.Wallet {
	return u.wallet
}

// ── helpers ───────────────────────────────────────────────────────────────────

func (u *Usecase) importAndPersist(
	ctx context.Context,
	mnemonic string,
	secretType entity.SecretType,
	label string,
) (*entity.Wallet, error) {
	w, err := ethkit.NewWalletFromMnemonic(mnemonic, ethkit.DefaultDerivationPath)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "derive wallet")
	}

	return u.persistWallet(ctx, w, mnemonic, secretType, label)
}

func (u *Usecase) persistWallet(
	ctx context.Context,
	w *ethkit.Wallet,
	secret string,
	secretType entity.SecretType,
	label string,
) (*entity.Wallet, error) {
	if err := u.keychain.Set(keychainKey, secret); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "store secret in keychain")
	}

	record := &entity.Wallet{
		ID:         u.ULID(),
		Address:    w.Address(),
		Label:      label,
		SecretType: secretType,
		CreatedAt:  u.NowUTC(),
	}
	if err := u.svc.Save(ctx, record); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "persist wallet record")
	}

	u.wallet = w
	u.log.InfoContext(ctx, "wallet imported",
		"address", w.Address().Short(), "type", secretType)

	return record, nil
}
