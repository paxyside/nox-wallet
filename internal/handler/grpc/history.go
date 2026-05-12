package grpc

import (
	"context"
	"strings"

	pricefeed "github.com/paxyside/nox-wallet/internal/adapter/price"
	historyuc "github.com/paxyside/nox-wallet/internal/usecase/history"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbcommon "github.com/paxyside/nox-wallet/proto/gen/go/wallet/common"
)

func (h *Handler) GetHistory(ctx context.Context, req *pb.GetHistoryRequest) (*pb.GetHistoryResponse, error) {
	addr := h.wallet.LoadedAddress()

	if a := req.GetAddress(); a != "" {
		parsed, err := ethkit.NewAddress(a)
		if err != nil {
			return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid address"))
		}

		addr = parsed
	}

	page := req.GetPage()

	limit := 20
	if page.GetLimit() > 0 {
		limit = int(page.GetLimit())
	}

	// Collect watched token contract addresses to use as an ERC-20 allow-list.
	// Only transfers involving these contracts will be synced from Alchemy,
	// blocking address-poisoning spam and airdrop junk at the source.
	var watchedContracts []ethkit.Address

	if tokenList, err := h.token.List(ctx); err == nil {
		for _, t := range tokenList {
			watchedContracts = append(watchedContracts, t.Token.Address)
		}
	}

	res, err := h.history.GetHistory(ctx, historyuc.GetHistoryParams{
		Address:          addr,
		Limit:            limit,
		Cursor:           page.GetCursor(),
		WatchedContracts: watchedContracts,
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	// Collect distinct asset symbols and resolve each to a contract
	// address through the embedded Uniswap Default List. ERC-20 rows
	// then price via CoinGecko's contract endpoint; native ETH stays
	// in the symbol-map path. Symbols that aren't in the tokenlist
	// fall through with empty Address and silently miss — those are
	// long-tail / spam tokens we don't have USD for anyway.
	symbolSet := map[string]struct{}{"ETH": {}}

	for _, tx := range res.Transactions {
		if s := tx.Asset; s != "" {
			symbolSet[strings.ToUpper(s)] = struct{}{}
		}
	}

	priceTokens := make([]pricefeed.PriceableToken, 0, len(symbolSet))
	for s := range symbolSet {
		t := pricefeed.PriceableToken{Symbol: s}
		if s != "ETH" {
			if addr, ok := h.tokenList.AddressBySymbol(h.chainID, s); ok {
				t.Address = addr
			}
		}
		priceTokens = append(priceTokens, t)
	}

	prices := h.prices.GetPricesForTokens(ctx, priceTokens)

	return &pb.GetHistoryResponse{
		Items: historyToProto(res, prices),
		PageInfo: &pbcommon.PageInfo{
			NextCursor: res.NextCursor,
			HasMore:    res.HasMore,
			TotalCount: int32(res.Total),
		},
	}, nil
}
