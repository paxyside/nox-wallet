# Contributing

This is a private repository. Outside contributions aren't being
accepted at v0 — once the project opens up these rules will replace
this paragraph.

For now, this file documents the conventions every commit on this
repo follows, whether it lands as a direct push or a PR.

## Setup

See [`docs/development.md`](docs/development.md). Don't open a PR
until `task prepare` passes locally.

## Code style

- **Go**: `gofmt` (enforced by `golangci-lint run --fix`),
  `golangci-lint` config in `.golangci.yaml`. Test files have a
  looser set of rules — see the `exclude-rules` block.
- **Dart**: `dart format --line-length=100`, `very_good_analysis`
  preset. `task prepare` fails if either reformatted anything.
- **Proto**: `buf format -w` runs as part of `task proto:generate`.

## Commit messages

Conventional Commits-ish, lower-case prefix, terse imperative
present tense:

```
feat(swap): apply 0.5% slippage at executeSwap time
fix(send): clear gas estimate on asset change
refactor(watcher): split classify out of process_tick
docs: regenerate after Flutter 3.41.9 format bump
ci: switch primary gate to ubuntu-latest
chore: bump go-ethereum to 1.16.5
```

Prefix vocabulary: `feat`, `fix`, `refactor`, `perf`, `style`,
`docs`, `test`, `ci`, `build`, `chore`. Scope is optional but
helpful (`feat(swap):`, `fix(watcher):`).

Body is optional. When you do write one, explain *why* — the diff
shows *what*.

## Branching

Working branch is `master`. There's no `main` / `develop` / `release`
split. Feature work happens on short-lived topic branches
(`feat/swap-slippage`, `fix/cmd-q-race`) that merge back into
`master` via PR.

## Pre-push checklist

```sh
task prepare        # everything green
git status          # working tree clean — no stray vendor/ or pubspec.lock drift
git log -1          # commit message stands on its own
```

CI runs the same `task prepare` and also `git diff --exit-code`. If
prepare mutated any tracked file you forgot to commit (vendored
deps, regenerated proto, reformatted Dart), CI fails with a clear
error.

## Reporting security issues

Don't open a public issue, even when the repo opens up. See
[`SECURITY.md`](SECURITY.md).
