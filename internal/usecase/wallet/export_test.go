package wallet

import "github.com/paxyside/nox-wallet/pkg/ethkit"

// SetWalletForTest installs an in-memory wallet on the usecase. Test-only.
func (u *Usecase) SetWalletForTest(w *ethkit.Wallet) {
	u.wallet = w
}
