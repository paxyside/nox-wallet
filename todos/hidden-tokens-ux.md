# Hidden tokens — visible management UI

Today the Tokens screen has a row-level "hide" affordance (eye icon),
which sets `is_hidden=true` in the DB and removes the row from all
visible token lists (dashboard widget, Tokens tab, Send/Swap pickers).

What's missing: **a way to see and un-hide tokens.** Currently the
only path back is to open the "Add Token" dialog and re-paste the
contract address — backend's `Add` now handles this gracefully and
flips `is_hidden=false` (see `internal/usecase/token/usecase.go`'s
idempotent Add path), but it's still a weird flow that requires the
user to remember the contract address of something they once owned.

## What's needed

- **Tokens screen filter:** add a "Show hidden" toggle (or three-state
  segmented control: Visible / Hidden / All).
- **Hidden row visual:** when shown, render hidden rows at reduced
  opacity with an "Unhide" pill instead of the regular eye-toggle.
  Make the state obvious — user shouldn't wonder why a row "looks
  different".
- **Per-row Unhide button** calling existing
  `Hide(id, hidden: false)` backend method. The endpoint already
  exists, just needs the UI.
- **Empty state** when filter is "Hidden" and there are no hidden
  tokens: short copy like "No hidden tokens. Hide one from the eye
  icon on a visible row to manage it here."

## Why this matters

It's the single most jarring UX bug in the app right now. User
discovered it by hiding USDT, then trying to add it back via the
contract dialog and getting a misleading error. Backend's idempotent
Add path fixed the data correctness; this fix closes the user-facing
loop.

## Scope

UI-only. Backend `Hide(id, hidden bool)` and gRPC `HideToken` already
take a flag. ListTokensWithBalances already returns hidden rows; UI
just filters them out — flipping that filter via a state variable
gets us most of the way.

## Done when

- [ ] Tokens screen has a Visible / Hidden filter
- [ ] Hidden tokens show with reduced opacity + Unhide action
- [ ] One-click unhide returns the token to visible state across all
      surfaces (dashboard, Tokens, Send/Swap pickers)
- [ ] Add Token dialog STILL works as a fallback (don't remove the
      idempotent backend behaviour)
