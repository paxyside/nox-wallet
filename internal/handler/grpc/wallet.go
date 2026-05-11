package grpc

import (
	"context"
	"fmt"

	"github.com/shopspring/decimal"

	walletentity "github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbwallet "github.com/paxyside/nox-wallet/proto/gen/go/wallet/wallet"
)

func (h *Handler) GenerateWallet(
	ctx context.Context,
	req *pb.GenerateWalletRequest,
) (*pb.GenerateWalletResponse, error) {
	res, err := h.wallet.GenerateWallet(ctx, walletuc.GenerateWalletParams{
		Label: req.GetLabel(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	w, err := h.wallet.GetWallet(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.GenerateWalletResponse{
		Wallet:   walletToProto(w),
		Mnemonic: res.Mnemonic,
	}, nil
}

func (h *Handler) ImportMnemonic(
	ctx context.Context,
	req *pb.ImportMnemonicRequest,
) (*pb.ImportMnemonicResponse, error) {
	w, err := h.wallet.ImportMnemonic(ctx, walletuc.ImportMnemonicParams{
		Mnemonic:       req.GetMnemonic(),
		Label:          req.GetLabel(),
		DerivationPath: req.GetDerivationPath(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	h.kickoffWalletSeed()

	return &pb.ImportMnemonicResponse{Wallet: walletToProto(w)}, nil
}

func (h *Handler) ImportPrivateKey(
	ctx context.Context,
	req *pb.ImportPrivateKeyRequest,
) (*pb.ImportPrivateKeyResponse, error) {
	w, err := h.wallet.ImportPrivateKey(ctx, walletuc.ImportPrivateKeyParams{
		PrivateKeyHex: req.GetPrivateKeyHex(),
		Label:         req.GetLabel(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	h.kickoffWalletSeed()

	return &pb.ImportPrivateKeyResponse{Wallet: walletToProto(w)}, nil
}

func (h *Handler) ImportKeystore(
	ctx context.Context,
	req *pb.ImportKeystoreRequest,
) (*pb.ImportKeystoreResponse, error) {
	w, err := h.wallet.ImportKeystore(ctx, walletuc.ImportKeystoreParams{
		KeystoreJSON: req.GetKeystoreJson(),
		Passphrase:   req.GetPassphrase(),
		Label:        req.GetLabel(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	h.kickoffWalletSeed()

	return &pb.ImportKeystoreResponse{Wallet: walletToProto(w)}, nil
}

// kickoffWalletSeed fires Alchemy-driven token discovery and history sync in
// the background. We don't await them — the import RPC returns immediately,
// and the UI re-polls ListTokensWithBalances and GetHistory a couple of times
// after the wallet appears so the freshly discovered tokens and transactions
// show up on Tokens / Dashboard / History within seconds.
//
// Previously this was only triggered indirectly via GetBalances(WithTokens)
// and GetHistory itself, which created a race where a user landing on the
// History tab first saw an empty list while the sync was still in flight.
func (h *Handler) kickoffWalletSeed() {
	addr := h.wallet.LoadedAddress()
	if addr.IsZero() {
		return
	}

	go func() {
		bgCtx := context.Background()
		if err := h.token.Seed(bgCtx, addr); err != nil {
			h.l.WarnContext(bgCtx, "post-import token seed failed", "error", err)
		}

		// History sync uses the watched-contract list to filter ERC-20 transfers
		// down to legitimate tokens (anti-spam). Run it after Seed so the list
		// already contains USDC/USDT/etc. discovered above.
		var watchedContracts []ethkit.Address
		if list, err := h.token.List(bgCtx); err == nil {
			watchedContracts = make([]ethkit.Address, 0, len(list))
			for _, t := range list {
				watchedContracts = append(watchedContracts, t.Token.Address)
			}
		}

		if err := h.history.Sync(bgCtx, addr, watchedContracts); err != nil {
			h.l.WarnContext(bgCtx, "post-import history sync failed", "error", err)
		}
	}()
}

func (h *Handler) ExportKeystore(
	ctx context.Context,
	req *pb.ExportKeystoreRequest,
) (*pb.ExportKeystoreResponse, error) {
	data, err := h.wallet.ExportKeystore(walletuc.ExportKeystoreParams{
		Passphrase: req.GetPassphrase(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.ExportKeystoreResponse{KeystoreJson: data}, nil
}

func (h *Handler) RevealSecret(ctx context.Context, _ *pb.RevealSecretRequest) (*pb.RevealSecretResponse, error) {
	res, err := h.wallet.RevealSecret(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	secretType := pbwallet.SecretType_SECRET_TYPE_UNSPECIFIED

	switch res.SecretType {
	case walletentity.SecretTypeMnemonic:
		secretType = pbwallet.SecretType_SECRET_TYPE_MNEMONIC
	case walletentity.SecretTypePrivateKey:
		secretType = pbwallet.SecretType_SECRET_TYPE_PRIVATE_KEY
	}

	return &pb.RevealSecretResponse{
		Secret:     res.Secret,
		SecretType: secretType,
	}, nil
}

func (h *Handler) GetWallet(ctx context.Context, _ *pb.GetWalletRequest) (*pb.GetWalletResponse, error) {
	w, err := h.wallet.GetWallet(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.GetWalletResponse{Wallet: walletToProto(w)}, nil
}

func (h *Handler) GetBalances(ctx context.Context, req *pb.GetBalancesRequest) (*pb.GetBalancesResponse, error) {
	addr := h.wallet.LoadedAddress()
	if addr.IsZero() {
		// No wallet — caller is the onboarding screen polling early.
		// Returning an empty response avoids hammering Alchemy with the
		// zero address (which returns spam tokens and ETH=0).
		return &pb.GetBalancesResponse{}, nil
	}

	var tokens []ethkit.Token

	if req.GetWithTokens() {
		// Token discovery hits Alchemy and is slow; we deliberately detach it from
		// the request context so client cancellations don't abort the partial sync.
		go func() {
			bgCtx := context.Background()
			if err := h.token.Seed(bgCtx, addr); err != nil {
				h.l.WarnContext(bgCtx, "token discovery failed", "error", err)
			}
		}()

		list, err := h.token.List(ctx)
		if err != nil {
			return nil, h.HandleError(ctx, err)
		}

		for _, t := range list {
			tokens = append(tokens, t.Token)
		}
	}

	res, err := h.wallet.GetBalances(ctx, walletuc.GetBalancesParams{
		Address: addr,
		Tokens:  tokens,
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	// Collect symbols for price lookup.
	symbols := make([]string, 0, len(res.Tokens)+1)

	symbols = append(symbols, "ETH")
	for _, tb := range res.Tokens {
		symbols = append(symbols, tb.Token.Symbol)
	}

	prices := h.prices.GetPrices(ctx, symbols)

	eth, wei, pbTokens := balancesToProto(res, prices)

	ethUsd := ""

	if ethPrice, ok := prices["ETH"]; ok {
		ethVal, _ := res.ETH.ToETH().Float64()
		ethUsd = formatUSD(ethVal * ethPrice)
	}

	return &pb.GetBalancesResponse{
		EthBalance:    eth,
		EthBalanceWei: wei,
		Tokens:        pbTokens,
		EthUsdValue:   ethUsd,
	}, nil
}

func (h *Handler) GetGasFees(ctx context.Context, _ *pb.GetGasFeesRequest) (*pb.GetGasFeesResponse, error) {
	res, err := h.wallet.GetGasFees(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	ethPriceUSD := ""
	if p := h.prices.GetPrice(ctx, "ETH"); p > 0 {
		ethPriceUSD = fmt.Sprintf("%.2f", p)
	}

	return &pb.GetGasFeesResponse{
		Fees:        gasFeesToProto(res),
		BlockNumber: res.BlockNumber,
		EthPriceUsd: ethPriceUSD,
	}, nil
}

func (h *Handler) SendETH(ctx context.Context, req *pb.SendETHRequest) (*pb.SendETHResponse, error) {
	to, err := ethkit.NewAddress(req.GetTo())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid to address"))
	}

	d, err := decimal.NewFromString(req.GetAmount())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid amount"))
	}

	receipt, err := h.wallet.SendETH(ctx, walletuc.SendETHParams{
		To:    to,
		Value: ethkit.NewAmountFromETH(d),
		Gas:   gasOptionsFromProto(req.GetGas()),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.SendETHResponse{Receipt: receiptToProto(receipt)}, nil
}

func (h *Handler) SendToken(ctx context.Context, req *pb.SendTokenRequest) (*pb.SendTokenResponse, error) {
	to, err := ethkit.NewAddress(req.GetTo())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid to address"))
	}

	tokenAddr, err := ethkit.NewAddress(req.GetTokenAddress())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token address"))
	}

	d, err := decimal.NewFromString(req.GetAmount())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid amount"))
	}

	receipt, err := h.wallet.SendToken(ctx, walletuc.SendTokenParams{
		To:           to,
		TokenAddress: tokenAddr,
		Amount:       d,
		Gas:          gasOptionsFromProto(req.GetGas()),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.SendTokenResponse{Receipt: receiptToProto(receipt)}, nil
}
