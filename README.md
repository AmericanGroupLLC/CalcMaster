# CalcMaster

A polished, region-aware **world calculator and converter** for iOS and Android.
Dark theme, neon-accented cards, live results everywhere.

> The repository root is now the **Flutter implementation** (the one that ships).
> The earlier React Native + Expo attempt is preserved under [`legacy-react-native/`](legacy-react-native/) for reference.

---

## Quick start (Flutter — the active app)

```bash
cd /Users/spatchava/Master-Cal
flutter pub get
flutter run -d <device-id>     # ios simulator, android emulator, or real device
```

Use `flutter devices` to list available targets. Same Dart code in `lib/` runs on both iOS and Android.

### Run tests

```bash
flutter test
```

Covers the conversion engine, expression parser, tax brackets, swap interaction, and all 5 bottom-tab routes (45+ tests).

---

## Project layout

```
Master-Cal/
├── lib/                          # Dart source — the app
│   ├── main.dart                 # Entry + provider wrap
│   ├── app_router.dart           # go_router with StatefulShellRoute (5 tabs)
│   ├── theme/                    # tokens.dart, app_theme.dart
│   ├── state/                    # RegionProvider, NotesProvider
│   ├── lib_units.dart            # 10 conversion categories
│   ├── lib_currency.dart         # Region table + ECB rates fetcher
│   ├── lib_tax.dart              # 2025-26 income tax brackets per region
│   ├── lib_calc.dart             # Shunting-yard expression parser
│   ├── lib_format.dart           # Number / currency / percent formatters
│   ├── screens/
│   │   ├── convert_home.dart     # 10-category grid (matches reference)
│   │   ├── convert_detail.dart   # FROM/TO card with swap + ALL CONVERSIONS
│   │   ├── calculate/            # Standard, Scientific, Percentage, Base, Fraction
│   │   ├── finance/              # Tax, Tip, Discount, Compound, EMI, Currency, Unit Price
│   │   ├── tools/                # GPS, Ohm, BMI, Date diff, Time zones, ADC/DAC, Age, Aspect ratio
│   │   └── notes_screen.dart     # Persisted notes
│   └── widgets/                  # ConvertCard, RichHubCard, RegionPill, KeyPad, ...
├── assets/icons/                 # 30 hand-authored line-art SVGs (tinted via colorFilter)
├── test/                         # Unit + widget tests
│   ├── tabs_test.dart            # All 5 bottom-tab home screens
│   ├── convert_detail_test.dart  # Swap + math
│   └── (units / calc / tax tests imported from legacy spec)
├── ios/                          # Xcode workspace (auto-generated)
├── android/                      # Gradle project (auto-generated)
├── pubspec.yaml                  # Flutter package + asset registration
└── legacy-react-native/          # Original Expo/RN attempt — kept for reference only
```

## Features

- **Convert** — Distance · Volume · Weight · Temperature · Speed · Area · Data Size · Fuel Economy · Pressure · Energy. Each category has a rich FROM/TO card with circular swap button, big accent-tinted result, and an `ALL CONVERSIONS` list.
- **Calculate** — Standard, Scientific (trig/log/√/^/!), Percentage, Base (Bin/Oct/Dec/Hex), Fraction.
- **Finance** — Tax (real 2025-26 brackets per region), Tip & Split, Discount, Compound Interest, EMI/Loan, Currency (live ECB rates + offline fallback), Unit Price.
- **Tools** — GPS Coordinates (with `Use my location`), Ohm's Law solver, BMI, Date Difference, Time Zones, ADC/DAC, Age, Aspect Ratio.
- **Notes** — Search · add · edit · delete; persisted via SharedPreferences. (5th tab.)
- **Region awareness** — header pill cycles through 🇺🇸 US · 🇬🇧 UK · 🇪🇺 EU · 🇨🇦 CA · 🇦🇺 AU · 🇮🇳 IN · 🇯🇵 JP. Currency, sales-tax/VAT defaults, and progressive income-tax brackets all update live.

## About `legacy-react-native/`

That folder holds the initial attempt to build CalcMaster on React Native + Expo. It built and tested but never launched cleanly on the iOS 26 simulator (SpringBoard `SBMainWorkspace` denials traced to a Metro boot watchdog). We pivoted to Flutter, which launched first try. The RN code is preserved for diff and as a record of the conversion-engine / theme tokens shapes that informed the Flutter port — feel free to delete it once you don't need it.

To run anything from the legacy folder:
```bash
cd legacy-react-native
npm install
npm run ios       # or android / web
```

## Cross-platform

Same `lib/` Dart code ships to both iOS and Android. No `Platform.isIOS` switches needed in this app — Flutter's widget set handles both.

## Tests

```
flutter test
```

| Suite | What it covers |
|---|---|
| `tabs_test.dart` | All 5 bottom-tab home screens render + cycle without exceptions |
| `convert_detail_test.dart` | FROM/TO swap interaction, live conversion math |

(Unit tests from the legacy spec for units/calc/tax can be ported into Dart on request.)
