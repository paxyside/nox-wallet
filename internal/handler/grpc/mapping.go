package grpc

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/shopspring/decimal"
	"google.golang.org/protobuf/types/known/timestamppb"

	pricefeed "github.com/paxyside/nox-wallet/internal/adapter/price"
	contactentity "github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	tokenentity "github.com/paxyside/nox-wallet/internal/domain/token/entity"
	transactionentity "github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	walletentity "github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	historyuc "github.com/paxyside/nox-wallet/internal/usecase/history"
	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	watcheruc "github.com/paxyside/nox-wallet/internal/usecase/watcher"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbbalance "github.com/paxyside/nox-wallet/proto/gen/go/wallet/balance"
	pbcontact "github.com/paxyside/nox-wallet/proto/gen/go/wallet/contact"
	pbevent "github.com/paxyside/nox-wallet/proto/gen/go/wallet/event"
	pbtoken "github.com/paxyside/nox-wallet/proto/gen/go/wallet/token"
	pbtransaction "github.com/paxyside/nox-wallet/proto/gen/go/wallet/transaction"
	pbwallet "github.com/paxyside/nox-wallet/proto/gen/go/wallet/wallet"
)

func walletToProto(w *walletentity.Wallet) *pbwallet.Wallet {
	return &pbwallet.Wallet{
		Id:         w.ID,
		Address:    w.Address.Hex(),
		Label:      w.Label,
		SecretType: secretTypeToProto(w.SecretType),
		CreatedAt:  timestamppb.New(w.CreatedAt),
	}
}

func secretTypeToProto(s walletentity.SecretType) pbwallet.SecretType {
	switch s {
	case walletentity.SecretTypeMnemonic:
		return pbwallet.SecretType_SECRET_TYPE_MNEMONIC
	case walletentity.SecretTypePrivateKey:
		return pbwallet.SecretType_SECRET_TYPE_PRIVATE_KEY
	default:
		return pbwallet.SecretType_SECRET_TYPE_UNSPECIFIED
	}
}

func balancesToProto(
	r walletuc.GetBalancesResult,
	prices pricefeed.Prices,
) (string, string, []*pbbalance.TokenBalance) {
	tokens := make([]*pbbalance.TokenBalance, 0, len(r.Tokens))
	for _, tb := range r.Tokens {
		usdValue := ""

		sym := strings.ToUpper(tb.Token.Symbol)
		if price, ok := prices[sym]; ok {
			bal, _ := tb.Balance.ToTokenUnits(tb.Token.Decimals).Float64()
			usdValue = formatUSD(bal * price)
		}

		tokens = append(tokens, &pbbalance.TokenBalance{
			Symbol:   tb.Token.Symbol,
			Name:     tb.Token.Name,
			Address:  tb.Token.Address.Hex(),
			Balance:  tb.Balance.ToTokenUnits(tb.Token.Decimals).String(),
			Decimals: uint32(tb.Token.Decimals),
			UsdValue: usdValue,
		})
	}

	return r.ETH.ToETH().String(), r.ETH.String(), tokens
}

func formatUSD(value float64) string {
	if value >= 0.01 {
		return fmt.Sprintf("$%.2f", value)
	}

	return fmt.Sprintf("$%.6f", value)
}

// ensure unused imports satisfied for compiler.
var _ = strings.ToUpper

func gasFeesToProto(r walletuc.GetGasFeesResult) *pbbalance.GasFees {
	return &pbbalance.GasFees{
		BaseFeeGwei:        r.GasInfo.BaseFee.ToGwei().StringFixed(4),
		MaxPriorityFeeGwei: r.GasInfo.PriorityFee.ToGwei().StringFixed(4),
		MaxFeeGwei:         r.GasInfo.MaxFee.ToGwei().StringFixed(4),
		EstimatedGas:       21_000,
		ChainId:            r.ChainID,
		BlockNumber:        r.BlockNumber,
	}
}

func receiptToProto(r ethkit.TxReceipt) *pbtransaction.TxReceipt {
	return &pbtransaction.TxReceipt{
		TxHash:                r.Hash,
		BlockNumber:           r.BlockNumber,
		GasUsed:               r.GasUsed,
		EffectiveGasPriceGwei: r.GasCost.FormatGwei(),
		Success:               r.Status == ethkit.TxStatusSuccess,
	}
}

func historyToProto(r historyuc.GetHistoryResult, prices pricefeed.Prices) []*pbtransaction.HistoryItem {
	items := make([]*pbtransaction.HistoryItem, 0, len(r.Transactions))
	for _, tx := range r.Transactions {
		items = append(items, txToProto(tx, prices))
	}

	return items
}

func txToProto(tx *transactionentity.Transaction, prices pricefeed.Prices) *pbtransaction.HistoryItem {
	// USD value of the transferred amount.
	valueUSD := ""

	sym := strings.ToUpper(tx.Asset)
	if sym == "" {
		sym = "ETH"
	}

	if price, ok := prices[sym]; ok {
		val, _ := tx.Value.Float64()
		valueUSD = fmt.Sprintf("$%.2f", val*price)
	}

	// USD value of the gas fee (computed from stored ETH amount + ETH price).
	gasFeeUsd := ""

	if tx.GasFeeEth != "" {
		if ethPrice, ok := prices["ETH"]; ok {
			if feeEth, err := strconv.ParseFloat(tx.GasFeeEth, 64); err == nil {
				gasFeeUsd = fmt.Sprintf("$%.2f", feeEth*ethPrice)
			}
		}
	}

	return &pbtransaction.HistoryItem{
		TxHash:    tx.Hash,
		From:      tx.From.Hex(),
		To:        tx.To.Hex(),
		Asset:     tx.Asset,
		Value:     tx.Value.String(),
		RawValue:  tx.Value.String(),
		BlockTime: timestamppb.New(tx.Timestamp),
		BlockNum:  tx.BlockNumber,
		Category:  string(tx.Category),
		ValueUsd:  valueUSD,
		GasFeeEth: tx.GasFeeEth,
		GasFeeUsd: gasFeeUsd,

		IsSwap:        tx.IsSwap,
		TokenInSym:    tx.TokenInSym,
		TokenInValue:  tx.TokenInVal,
		TokenOutSym:   tx.TokenOutSym,
		TokenOutValue: tx.TokenOutVal,
	}
}

func contactToProto(c *contactentity.Contact) *pbcontact.Contact {
	return &pbcontact.Contact{
		Id:         c.ID,
		Name:       c.Name,
		Address:    c.Address.Hex(),
		Note:       c.Notes,
		IsFavorite: c.IsFavorite,
		CreatedAt:  timestamppb.New(c.CreatedAt),
		UpdatedAt:  timestamppb.New(c.UpdatedAt),
	}
}

func watchedTokenToProto(t *tokenentity.WatchedToken) *pbtoken.WatchedToken {
	return &pbtoken.WatchedToken{
		Id:       t.ID,
		Address:  t.Token.Address.Hex(),
		Symbol:   t.Token.Symbol,
		Name:     t.Token.Name,
		Decimals: uint32(t.Token.Decimals),
		AddedAt:  timestamppb.New(t.AddedAt),
		IsPinned: t.IsPinned,
		IsHidden: t.IsHidden,
	}
}

func tokenWithBalanceToProto(t tokenuc.TokenWithBalance) *pbtoken.WatchedTokenWithBalance {
	tok := &pbtoken.WatchedToken{
		Id:       t.ID,
		Address:  t.Token.Address.Hex(),
		Symbol:   t.Token.Symbol,
		Name:     t.Token.Name,
		Decimals: uint32(t.Token.Decimals),
		IsPinned: t.IsPinned,
		IsHidden: t.IsHidden,
	}

	balUSD := ""
	if t.BalanceUSD > 0 {
		balUSD = fmt.Sprintf("$%.2f", t.BalanceUSD)
	}

	var market *pbtoken.TokenMarketData

	if t.PriceUSD > 0 || len(t.Sparkline7d) > 0 {
		changeStr := fmt.Sprintf("%.2f", t.Change24hPct)
		if t.Change24hPct > 0 {
			changeStr = "+" + changeStr
		}

		market = &pbtoken.TokenMarketData{
			PriceUsd:       fmt.Sprintf("%.6g", t.PriceUSD),
			Change_24HPct:  changeStr,
			ChangePositive: t.ChangePositive,
			Sparkline_7D:   t.Sparkline7d,
			Sparkline_30D:  t.Sparkline30d,
		}
	}

	return &pbtoken.WatchedTokenWithBalance{
		Token:      tok,
		Balance:    t.Balance.ToTokenUnits(t.Token.Decimals).String(),
		BalanceUsd: balUSD,
		Market:     market,
	}
}

// ── WatchEvents (unified) ─────────────────────────────────────────────────────

// walletEventToProto delegates to the watcher package: the watcher
// itself needs the same mapping for SQLite persistence, so the canonical
// implementation lives there. Kept as a local alias so this file (which
// is the legacy single-source-of-truth for proto mapping) still
// compiles untouched.
func walletEventToProto(e watcheruc.WalletEvent) *pbevent.WalletEvent {
	return watcheruc.WalletEventToProto(e)
}

// gasOptionsFromProto translates the optional GasOptions message into the
// usecase-level GasOverride struct. Empty / blank fields fall through as
// nil pointers so the wallet usecase keeps the network-suggested values.
func gasOptionsFromProto(g *pb.GasOptions) walletuc.GasOverride {
	if g == nil {
		return walletuc.GasOverride{}
	}

	out := walletuc.GasOverride{}
	if s := strings.TrimSpace(g.GetPriorityGwei()); s != "" {
		if d, err := decimal.NewFromString(s); err == nil {
			out.PriorityGwei = &d
		}
	}
	if s := strings.TrimSpace(g.GetMaxGwei()); s != "" {
		if d, err := decimal.NewFromString(s); err == nil {
			out.MaxGwei = &d
		}
	}
	return out
}
