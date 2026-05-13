# Settings screen layout rework

The Settings screen grew organically — Wallet, Security, About,
Danger Zone all stacked vertically with the same visual rhythm.
After the About / Updates section landed, things spilled past the
visible area on smaller windows and the hierarchy reads flat.
Wrapped in `SingleChildScrollView` as a quick fix so nothing's
unreachable, but it's a band-aid.

## What's needed

- **Visual hierarchy.** Right now every section is one of N
  uniformly-styled cards. Group related items: Wallet + Security
  together (identity / safety), About on its own, Danger Zone visually
  separated with stronger affordance (red accent border, confirmation
  modal already in place but presentation could be louder).
- **Tighter density.** Auto-lock dropdown + Hide balances toggle +
  Reveal / Export buttons could fit a denser two-column grid instead
  of the current full-width-per-row.
- **Better empty / loading states.** Wallet section currently renders
  a skeleton — fine, but the error banner takes up disproportionate
  visual space.
- **Possibly a left-rail subnav** if Settings keeps growing
  (Custom RPC, future Theme picker, future Currency picker, etc).
  Mirrors the main app sidebar — feels consistent.

## Sketch / mockup

User plans to iterate via GPT-generated mockups; this todo is a
parking spot for the redesign work. No constraints — full creative
licence on the visual.

## Done when

- [ ] Settings fits a 1000×600 window without scroll, OR scroll is
      deliberate and the rhythm explains it
- [ ] Sections grouped by intent, not just stacked
- [ ] Danger Zone reads as "danger" at a glance
- [ ] Existing functionality preserved: wallet info, auto-lock, hide
      balances, reveal secret, export keystore, check for updates,
      import new wallet
