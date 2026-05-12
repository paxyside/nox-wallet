# WalletConnect v2

User question: "WalletConnect — sites in browser usually connect via
extension, not desktop wallet, will this even work?"

**Short answer: yes, but via a different mechanism.**

## How WalletConnect works

WalletConnect is a *protocol*, not an extension. Two flavors:

1. **In-browser extension** (MetaMask, Phantom) — sites talk to a
   browser extension over `window.ethereum`. Different protocol entirely.
2. **WalletConnect** — sites generate a QR code or `wc:` deep link.
   The user scans / clicks it from their wallet app (mobile, *or
   desktop*), which opens a session via WalletConnect's relay
   network. The dApp doesn't care if the wallet is on the same machine
   or a phone in another country — it goes through the relay.

So Nox would be a desktop WalletConnect wallet — same role as Trust
Wallet on phone, just on macOS. dApp shows QR / `wc:` link → user
clicks → Nox opens session and signs requests.

## Integration

WalletConnect SDK for Dart: [`web3wallet_flutter`](https://pub.dev/packages/web3wallet_flutter)
(by Reown / WalletConnect Foundation). Active maintenance, supports v2.

### Frontend pieces

- New screen: `features/walletconnect/` with:
  - **Pair**: paste `wc:...` URI or open from clipboard, parse, show
    dApp metadata (name, icon, requested namespaces).
  - **Approve session**: explicit user confirmation. Don't allow
    `eth_signTypedData` / `eth_sendTransaction` without confirming
    each message in a popup — phishing prevention.
  - **Active sessions list**: show connected dApps, allow
    disconnect.
- New native channel `nox/clipboard_url` to detect pasted `wc:` link
  in the title bar (similar pattern to existing channels).

### Backend pieces

- Web3Wallet runs in Dart on the UI side actually — it doesn't need a
  Go counterpart. Signing requests come via the SDK, get forwarded
  to the gRPC `SendETH` / `SendToken` / `Sign` RPCs.
- New gRPC method **`PersonalSign`** for signing messages without
  broadcasting (currently no signing-only RPC exists). Implementation:
  `wallet.PersonalSign(message)` → keystore signs → return signature.
- New gRPC method **`SignTypedData`** for EIP-712.
- Maybe rename `SendETH` to `SignAndBroadcast` — WalletConnect dApps
  often want raw signed tx without broadcast (the dApp broadcasts
  itself). Decide based on what the SDK gives us.

### Security

This is the riskiest feature in the app — a phishing dApp can ask the
user to sign approval / permit2 / setApprovalForAll on their entire
balance. Mitigations:

- **Decoded transaction preview** — for every pending sign-request,
  decode calldata against known ABIs (Uniswap, ERC-20, ERC-721) and
  show "You are approving 100 USDC to be spent by 0xRouter…". For
  unknown calldata, show raw bytes + warning "we couldn't decode
  this — proceed at your own risk".
- **Domain origin check** — show the dApp domain prominently. If
  domain isn't in a known-safe list, show a warning banner.
- **Gas-limit ceiling** — refuse to sign txs with gasLimit beyond
  a sanity bound.
- **Per-session whitelist** — let the user limit a session to specific
  contracts (advanced setting).

### Phases

1. **MVP**: pair, list sessions, approve/reject signs with raw
  decoded payload visible. No decoding helpers yet, just hex.
2. **Decoding**: add ABI-based decoding for top 50 dApps + standard
  ERC-20 / ERC-721 / Uniswap V2/V3 routers.
3. **Polish**: persistent sessions across restarts, push
  notifications when a sign request arrives while app is in tray.

## Open questions

- Should pairing happen via deep link (`nox://wc?uri=...`) registered
  as a URL scheme in `Info.plist`? Better UX than copy-paste.
- Where does WC session state live — Dart only, or mirror to backend
  SQLite for restart persistence?
- Does WalletConnect's relay charge for traffic above a certain
  threshold? (Need to check pricing — currently free-tier exists.)

## Done when

- [ ] User can paste a `wc:` link from any web dApp and connect
- [ ] Sign request prompts a confirmation dialog with decoded
  calldata
- [ ] Sessions persist across app restart
- [ ] At least 5 of the major dApps tested end-to-end
  (Uniswap, Aave, Curve, Compound, OpenSea)
