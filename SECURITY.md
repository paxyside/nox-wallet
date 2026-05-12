# Security Policy

Nox-Wallet is a noncustodial Ethereum wallet that holds keys on the
user's device. A vulnerability in this codebase could lead directly to
loss of funds — please report any concerns privately rather than
opening a public issue.

## Reporting a vulnerability

Email **pavel.grebnev21@gmail.com** with:

- a short description of the issue,
- reproduction steps or a proof-of-concept,
- the commit SHA / release version you tested against,
- your preferred contact handle for follow-up.

You can expect an acknowledgement within **72 hours** and a status
update at least every **7 days** until the report is resolved or
closed. Fixes ship in the next patched release; we credit reporters in
the release notes unless you ask to stay anonymous.

## In scope

- The Go backend in `cmd/`, `internal/`, `pkg/`.
- The Flutter UI in `ui/`.
- Build / packaging scripts that affect what ends up in a shipped DMG.
- Anything in `proto/` that defines the wire contract between backend
  and UI.

## Out of scope

- Upstream issues in `go-ethereum`, Flutter SDK, or any other
  vendored dependency — report those upstream.
- Phishing attacks that depend on the user installing an unsigned
  third-party build masquerading as Nox Wallet.
- Findings that require physical access to an unlocked machine.
- Issues that require the user to manually type a known-bad mnemonic.

## What we DON'T want

- Public disclosure before a fix has shipped — please give us a chance
  to patch first.
- Automated scanner output without a manual triage step. We read every
  report, but raw scanner dumps without context are noise.

## Hardening already in place

For context, see the **Security posture** section of the README. The
short list:

- Wallet secrets live exclusively in the macOS Keychain, never in
  SQLite or any file we write.
- gRPC is loopback-only (`127.0.0.1`).
- The macOS bundle ships with the App Sandbox entitlement;
  network-client + server only.
- No telemetry: zero outbound calls except Alchemy, CoinGecko, and
  Etherscan (user-initiated).
