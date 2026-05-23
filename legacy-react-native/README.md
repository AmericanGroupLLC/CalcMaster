# CalcMaster

A polished, location-aware **world calculator and converter** built with React Native + Expo.
Dark theme, neon-accented cards, live results everywhere.

> **Status:** v4 — all four tabs functional. See [`docs/SPEC.md`](docs/SPEC.md) for the original product brief.

## Features

- **Convert** — Distance, Volume, Weight, Temperature, Speed, Area, Data Size, Fuel Economy, Pressure, Energy
- **Calculate** — Standard, Scientific, Percentage, Base (Bin/Oct/Dec/Hex), Fraction
- **Finance** — Tax, Tip & Split, Discount, Compound Interest, EMI/Loan, Currency, Unit Price
- **Tools** — GPS Coordinates, Ohm's Law, BMI, Date Difference, Time Zones, ADC/DAC, Age, Aspect Ratio
- **Region-aware** — tap the pill in the header to cycle through 🇺🇸 US · 🇬🇧 UK · 🇪🇺 EU · 🇨🇦 CA · 🇦🇺 AU · 🇮🇳 IN · 🇯🇵 JP. Currency, sales tax / VAT defaults, and progressive income-tax brackets all update live.
- **Notes** — long-press any result row to save it; full list available via the bookmark icon on the Tools hub.
- **Offline-friendly** — currency rates fetched from `frankfurter.app`, with a static fallback if the network is unavailable.

## Quick start

```bash
cd /Users/spatchava/Master-Cal
npm install
npm run ios       # or:  npm run android  /  npm run web
```

> Requires Node ≥ 18, Xcode (for iOS Simulator) or Android Studio (for emulator),
> and the Expo CLI (auto-installed via `npx`).

## Project structure

```
app/
  _layout.tsx                    # Root providers + status bar
  (tabs)/
    _layout.tsx                  # Bottom tab bar
    convert/                     # Convert home + dynamic [category] detail
    calculate/                   # Hub + 5 calculators
    finance/                     # Hub + 7 calculators
    tools/                       # Hub + 8 utilities
  notes.tsx                      # Modal route
  components/                    # Card, ChipPicker, HubTile, KeyPad, NumberInput, ...
  lib/                           # units, currency, tax, calc, format, storage  (pure TS)
  state/                         # RegionProvider, NotesProvider
  theme/tokens.ts                # Colors, radii, spacing, typography
__tests__/                       # units / calc / tax unit tests
docs/SPEC.md                     # Original product brief
```

The libraries under `app/lib/` have **no React dependency** and are unit-tested with Jest.

## Region awareness

The `RegionProvider` in `app/state/RegionProvider.tsx` exposes:

- `region` — current `{ id, label, flag, currency, symbol, locale }`
- `setRegion(id)` / `cycleRegion()` — change the active region; persisted with AsyncStorage
- `rates` — currency exchange rates (live or static)

Every screen that shows currency or tax pulls from this single source of truth, so updating
the region instantly re-renders the whole app.

## Tax brackets

`app/lib/tax.ts` ships 2025–2026 income-tax brackets for all 7 supported regions, plus a
`computeIncomeTax(gross, region, status)` helper. **These figures are intended for rough
estimates only** and are not a substitute for professional tax advice.

## Tests

```bash
npm test
```

Unit tests cover:

- All 10 conversion categories (`__tests__/units.test.ts`)
- The expression parser, scientific functions, and fraction simplification (`__tests__/calc.test.ts`)
- Income-tax computation across regions (`__tests__/tax.test.ts`)

## Adding a new converter category

1. Add a new entry to `categories` in `app/lib/units.ts` (units, factors, accent).
2. Pick an accent color in `app/theme/tokens.ts` if needed.
3. Add an Ionicons icon name on the new entry — that's it. The home grid and detail screen
   render every category dynamically.

## Design system

All visual styles flow from `app/theme/tokens.ts`. The reference screen (Convert home) is
rendered using only these tokens — no platform-specific styling — so swapping the theme
or adding a light variant is a 10-minute change.

## Roadmap

The original brief lists optional v5 ideas (Cooking, Clothing & Shoe Size, Savings Goal,
Roman Numeral, Angle, Password Generator, Budget Tracker). They're not built yet — drop
new categories into `app/lib/units.ts` and new screens under `app/(tabs)/...` to add them.
