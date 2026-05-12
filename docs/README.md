# Documentation

Living deep-dive docs for Nox Wallet. Pick one of the four pages
depending on where your question sits.

| Page                                   | When to read it                                                                                                                     |
|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| [**architecture.md**](architecture.md) | Big-picture: how the Flutter UI, Go backend, and macOS host wire together. Diagrams, process model, data flow, layering principles. |
| [**backend.md**](backend.md)           | Go side: package layout, hexagonal layering, watcher mechanics, Alchemy integration, SQLite migrations, ethkit internals.           |
| [**frontend.md**](frontend.md)         | Flutter side: Riverpod conventions, feature-sliced structure, native method channels, tray-resident pattern, notification flow.     |
| [**development.md**](development.md)   | Day-to-day: prerequisites, setup, the `task` runner, pre-commit checks, common gotchas.                                             |

For security policy + how to report a vulnerability, see
[`/SECURITY.md`](../SECURITY.md). For contribution norms, see
[`/CONTRIBUTING.md`](../CONTRIBUTING.md). For behavioural rules, see
[`/CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md).
