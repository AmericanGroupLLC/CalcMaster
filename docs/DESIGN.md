# Design — CalcMaster

## Overview
CalcMaster is a region-aware **world calculator and converter** built with Flutter for
iOS, Android and Web. It bundles unit conversion, general/scientific calculators, finance
tools, engineering/utility tools, notes and an optional AI chat into one offline-first app,
localized into 12 languages across 11 regions.

It is a **single client application**. There is no custom backend owned by this repo; all
core math runs on-device, and the few network features lean on managed third-party services.

## Layers
```
UI (screens/ + widgets/)            Flutter widgets, go_router navigation
        │  reads/updates
State (state/ + monetization/*Provider)   Provider / ChangeNotifier
        │  calls
Domain / logic (lib_*.dart)         pure-Dart, offline: units, currency, tax, calc, format
        │  optional
Services (services/, monetization/*Service)  Supabase, HTTP FX, AdMob, RevenueCat, Firebase
```
- **UI ↔ State ↔ Domain** is fully offline and deterministic.
- **Services** are thin, singleton, and each degrades gracefully (no-op) when unconfigured.

## Modules
| Module | Responsibility | Path |
| --- | --- | --- |
| Convert | 10 unit categories (distance, volume, weight, temperature, speed, area, data, fuel, pressure, energy) with per-unit to/from-base functions | `lib/lib_units.dart` |
| Calculate | Standard, scientific, percentage, base-N, fraction calculators | `lib/screens/calculate/`, `lib/lib_calc.dart` |
| Finance | Tax, tip, discount, compound interest, EMI, currency, unit-price | `lib/screens/finance/`, `lib/lib_tax.dart` |
| Tools | GPS, Ohm's law, BMI, date-diff, time zones, ADC/DAC, age, aspect ratio, calendar | `lib/screens/tools/` |
| Notes | Local notes CRUD | `lib/screens/notes_screen.dart`, `lib/state/notes_provider.dart` |
| AI chat | Optional assistant over the API gateway | `lib/screens/ai/`, `lib/state/ai_chat_provider.dart` |
| Currency/region | Region model, static + live FX rates, GPS auto-detect | `lib/lib_currency.dart`, `lib/state/region_provider.dart` |
| Monetization | Ads, subscriptions, affiliates, analytics, push — all flag-gated | `lib/monetization/` |

## Data & persistence
- **On-device (SharedPreferences):** selected region + auto-detect flag (`region_provider.dart`),
  notes serialized as JSON (`notes_provider.dart`).
- **Session (Supabase / GoTrue):** authentication + session refresh handled by the SDK;
  `AuthProvider` mirrors status into the UI. A **demo mode** lets users browse without an account.
- **No app-owned database.** Currency rates come from the free Frankfurter/ECB API
  (`api.frankfurter.app`), falling back to bundled `staticRates` when offline.
- **API gateway** (`services/api_client.dart`, `API_BASE_URL` dart-define) is used only for
  profile + AI chat, authorized with the current Supabase JWT as a bearer token.

## Navigation / flow
`main()` → Supabase init (guarded) + service bootstrap → `MaterialApp.router`.
- `initialLocation: /splash` — a ~2s branded animated splash.
- A `StatefulShellRoute.indexedStack` hosts five persistent tab branches with independent
  navigator keys: **Convert · Calculate · Finance · Tools · Notes** (`widgets/tab_scaffold.dart`,
  which switches to a side-rail desktop layout at ≥840px width, max content 1120px).
- Nested routes per branch (e.g. `/convert/:id`, `/finance/emi`).
- Modal routes pushed over the shell: `/settings`, `/paywall`, `/privacy`, `/about`,
  `/login`, `/ai-chat`.

## Key models
- `Unit` / `Category` (`lib_units.dart`) — conversion via `toBase`/`fromBase` closures.
- `Region` + `RegionId` enum (`lib_currency.dart`) — 11 regions (US, UK, EU, CA, AU, IN, JP,
  BR, MX, KR, AE), each with currency/symbol/locale. Enum names are persisted, so they stay uppercase.
- `Note` (`notes_provider.dart`) — id/title/body/created/updated, JSON (de)serializable.
- `ChatMessage` (`ai_chat_provider.dart`) — role/content/timestamp, plus a loading placeholder.

## Theme
Dark, "futuristic AI" aesthetic defined by tokens in `lib/theme/tokens.dart`:
- `AppColors` — base `#0B1020`, surfaces, violet accent `#7C5CFF`, semantic danger/success/warning.
- `CategoryAccent` — a distinct accent per conversion category.
- `Radii` / `Spacing` scales.
- `app_theme.dart` builds the `ThemeData`; `main.dart` overlays Google Fonts **Inter**.
- Signature widgets: `glass_card` (frosted BackdropFilter), `glow_text`,
  `animated_gradient_background`, `particle_dot_grid`.

## Services & config
- **Single source of truth:** `lib/monetization/monetization_config.dart` holds every
  credential/ID/URL and five master switches — `adsEnabled`, `subscriptionsEnabled`,
  `affiliatesEnabled`, `analyticsEnabled`, `fcmEnabled` — all **default `false`**. Defaults
  are Google TEST ad-unit IDs and dummy keys, so the app is safe to run/ship before wiring
  real monetization. Each service in `lib/monetization/` short-circuits until its flag flips.
- **Supabase:** `services/supabase_config.dart` (URL + publishable anon key, `--dart-define`
  overridable; OAuth redirect scheme = bundle id).
- **Localization:** ARB files in `lib/l10n/` (`app_en.arb` is source of truth) compiled by
  `flutter gen-l10n` into `lib/l10n/generated/`; RTL (Arabic) auto-handled by MaterialApp.

## Platform
- **iOS:** `ios/Runner.xcworkspace`, CocoaPods (SPM disabled to avoid an ads/plugin collision),
  app icons in `AppIcon.appiconset` (opaque, no alpha). Display name **CalcMaster**.
- **Android:** Gradle project, `applicationId com.americangroupllc.calcmaster`, launcher icons
  in `mipmap-*`, label **CalcMaster**; permissions: INTERNET, NETWORK_STATE, FINE/COARSE
  LOCATION (GPS tool), POST_NOTIFICATIONS.
- **Web:** Flutter web shell in `web/`, desktop layout via the tab scaffold breakpoint.
- Icons/splash generated by `flutter_launcher_icons` / `flutter_native_splash` from
  `assets/icon/` and `assets/splash/` (sources produced by `tools/gen_icon.dart`). Brand
  logo master lives in `assets/logo/`.

## Testing
- `flutter test` — unit + widget tests in `test/`.
- `integration_test/` — integration/E2E scaffold.
- `flutter analyze` — clean of errors/warnings; remaining items are intentional info-level
  style lints (uppercase `RegionId` enum names that must stay for persistence, a few
  `curly_braces_in_flow_control_structures`, and formula variable names like `PMT`).

## Out of scope
Custom server/database, hardware integration beyond GPS, and theming beyond the built-in
dark design system.
