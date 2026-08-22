# AGENTS.md — CalcMaster

**What:** Flutter world calculator + converter (10 unit categories, 5 calculators, 7 finance tools, 9 utility tools, notes, AI chat) — 12 locales, 11 regions, offline-first.

## Run commands
```bash
FLUTTER=/Users/spatchava/agl/.flutter-sdk/bin/flutter   # pinned SDK
$FLUTTER pub get
$FLUTTER run -d chrome            # or an iOS sim / Android emu id
$FLUTTER analyze                  # lint (info-level lints are pre-existing)
$FLUTTER test                     # unit + widget tests
$FLUTTER gen-l10n                 # regenerate lib/l10n/generated from ARB
dart run tools/gen_icon.dart      # regenerate icon/splash masters
```
Optional dart-defines: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL`.

## Architecture
Single Flutter client targeting **iOS and Android only**. Provider (ChangeNotifier) state + go_router nav; pure-Dart calc/convert libs run offline; thin external services (Supabase auth, Frankfurter FX, AdMob/Firebase all flag-gated).

## File map
| Path | Responsibility |
| --- | --- |
| `lib/main.dart` | Entry: Supabase init, MultiProvider, `MaterialApp.router`, i18n setup |
| `lib/app_router.dart` | go_router: `/splash` → 5-branch `StatefulShellRoute` (tabs) + modal routes |
| `lib/theme/tokens.dart` | `AppColors`, `CategoryAccent`, `Radii`, `Spacing` — design tokens |
| `lib/theme/app_theme.dart` | `buildAppTheme()` ThemeData (dark) |
| `lib/lib_units.dart` | `Unit`/`Category` models + 10 conversion categories (to/from base fns) |
| `lib/lib_currency.dart` | `RegionId` enum, 11 `Region`s, `staticRates`, Frankfurter fetcher |
| `lib/lib_tax.dart` | 2025-26 income-tax brackets per region |
| `lib/lib_calc.dart` | Shunting-yard expression parser/evaluator |
| `lib/lib_format.dart` | Locale-aware number/currency/percent formatting (intl) |
| `lib/i18n_helpers.dart` | category id → localized label mapping |
| `lib/l10n/` | `app_*.arb` (12 locales) + `generated/` (gen-l10n output) |
| `lib/state/region_provider.dart` | Selected region, live FX rates, GPS auto-detect |
| `lib/state/notes_provider.dart` | `Note` model + CRUD, persisted to SharedPreferences (JSON) |
| `lib/state/auth_provider.dart` | Supabase auth status, demo mode |
| `lib/state/ai_chat_provider.dart` | `ChatMessage` list, calls `ApiClient.sendAiMessage` |
| `lib/monetization/monetization_config.dart` | ⭐ ALL credentials + 5 master feature flags (default off) |
| `lib/monetization/*_service.dart` | ad / analytics / affiliate / notification / tracking singletons (no-op until flag on) |
| `lib/monetization/premium_provider.dart` + `premium_gate.dart` | Pro entitlement state + gating |
| `lib/services/supabase_config.dart` | Supabase URL/anon key (env-overridable) |
| `lib/services/api_client.dart` | REST gateway (Supabase JWT bearer) for profile + AI chat |
| `lib/screens/` | Feature screens grouped: `calculate/`, `finance/`, `tools/`, `ai/`, `auth/` + top-level |
| `lib/widgets/` | Reusable UI: `tab_scaffold`, `glass_card`, `hub_tile`, `number_input`, `banner_ad_slot`, etc. |
| `assets/icons/` | 32 line-art SVG category icons |
| `assets/logo/` | Brand logo master (`calcmaster_icon/logo.svg` + `.png`) |
| `assets/icon/`, `assets/splash/` | flutter_launcher_icons / native_splash source PNGs |
| `tools/` | `gen_icon.dart`, `release_all.sh`, marketing capture scripts |
| `docs/DESIGN.md` | Full architecture/design doc |

## Flow
`main()` → `/splash` (2s animated) → `TabScaffold` (bottom nav / desktop rail) with 5 branches: **Convert** (`/convert` → `/convert/:id`) · **Calculate** (`/calculate/{standard,scientific,percentage,base,fraction}`) · **Finance** (`/finance/{tax,tip,discount,compound,emi,currency,unit-price}`) · **Tools** (`/tools/{gps,ohm,bmi,date-diff,time-zones,adc-dac,age,aspect-ratio,calendar}`) · **Notes**. Modal routes over the shell: `/settings /paywall /privacy /about /login /ai-chat`.

## State management
Provider / ChangeNotifier via `MultiProvider` in `main.dart`: `RegionProvider`, `NotesProvider`, `PremiumProvider`, `AuthProvider`. Persistence = SharedPreferences (region, notes) + Supabase (session). No backend DB owned by this repo.

## Where to change X
| Task | Location |
| --- | --- |
| Add a conversion category / unit | `lib/lib_units.dart` (+ SVG in `assets/icons/`, label in `i18n_helpers.dart` + ARB) |
| Add a calculator/finance/tool screen | add screen in `lib/screens/<group>/`, register `GoRoute` in `app_router.dart`, tile in that group's `*_home.dart` |
| Add/change a region or currency | `lib/lib_currency.dart` (and `lib/lib_tax.dart` for tax) |
| Change colors/spacing/typography | `lib/theme/tokens.dart` / `app_theme.dart` |
| Add/translate UI strings | `lib/l10n/app_en.arb` (source) + other `app_*.arb`, then `flutter gen-l10n` |
| Monetization keys / toggle ads-subs-affiliates-analytics-fcm | `lib/monetization/monetization_config.dart` |
| App icon / splash | edit `assets/logo/*.svg`, re-render, run `dart run tools/gen_icon.dart` then `flutter_launcher_icons`/`native_splash` |
| Auth / AI backend endpoints | `lib/services/supabase_config.dart`, `lib/services/api_client.dart` |

## Gotchas
- **Pinned Flutter SDK** at `/Users/spatchava/agl/.flutter-sdk/bin/flutter` — use it, not a global `flutter`.
- **`archive` pinned to ^3.6.1** via `dependency_overrides` (image pkg needs it for icon/splash tooling).
- **CocoaPods forced** (`enable-swift-package-manager: false`) — google_mobile_ads vs SPM collision.
- **Monetization**: `adsEnabled` is **true**; the other four flags are `false` and those services no-op. Android carries real AdMob unit IDs; **iOS still carries Google's public TEST IDs**, so `AdService.enabled` refuses to serve ads on iOS in *release* builds (debug still shows test ads). Paste real iOS IDs into `monetization_config.dart` + `ios/Runner/Info.plist` to switch iOS ads on.
- **Subscriptions fail closed.** `PremiumProvider` grants Pro only when a backend confirms the store receipt (`RECEIPT_VERIFICATION_PATH`). With no endpoint configured, a completed purchase does **not** grant Pro — this is deliberate; a client-side grant is forgeable. `subscriptionsEnabled` stays `false` until that endpoint exists.
- **`InAppPurchase.instance` is resolved lazily** in `premium_provider.dart` — touching it eagerly opened a Play Billing connection even with subscriptions off, and threw under `flutter test`.
- **Unary minus is a real prefix operator** in `lib_calc.dart` (precedence 3, between `*` and `^`), not `(-1)*` desugaring — that older trick made `2^-3` evaluate to `1.5`.
- **RegionId enum values are UPPERCASE** (`US`, `UK`…) and persisted by `.name` in SharedPreferences — do NOT rename (the `constant_identifier_names` lint here is intentional/ignore).
- **`flutter analyze` reports ~info-level lints** (enum names, curly braces) that are pre-existing and intentional; only the previously-unreferenced `_white` warning was cleaned up.
- **Bundle/app id** is `com.americangroupllc.calcmaster` (Supabase OAuth redirect scheme depends on it) — leave it.
- **Mobile-only repo.** The `web/` platform dir and the React Native / Expo / Electron / browser-extension / NestJS-backend trees were removed — this repo builds iOS and Android and nothing else. `kIsWeb` guards remain in `lib/` as harmless defensive code, as does the >840px wide layout in `tab_scaffold.dart` (it still applies to tablets).
- Generated l10n (`lib/l10n/generated/`) is committed but regenerable — edit ARB, not the generated files.

## Authentication (login is OPTIONAL)

CalcMaster does **not** require an account. The app opens directly to the
calculator home as a **guest** — there is no forced login gate.

- **Startup**: `lib/screens/splash_screen.dart` always routes to `/calculate`
  after the splash animation. It never sends unauthenticated users to `/login`.
- **Guest choice is persisted** via `shared_preferences`
  (`lib/services/auth_service.dart`, key `guest_mode`), so relaunches never
  re-prompt for sign-in.
- **Optional sign-in** is reachable only on demand — `Settings → Sign in`
  (`context.push('/login')`) — and only unlocks optional cloud features.
- **Login screen** (`lib/screens/auth/login_screen.dart`) offers email/password
  and Google sign-in, a prominent **"Continue without account"** button, a
  **"Skip for now"** link, and a **"Use test account"** button
  (`SupabaseConfig.qaEmail` / `qaPassword`).
- **Supabase** is initialised in `main()` inside a try/catch with
  `Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey)`.
  Sign-in uses `Supabase.instance.client.auth.signInWithPassword(...)`.
- **Offline fallback**: if sign-in fails with a network/socket error AND the
  entered credentials match a `SupabaseConfig` test account (QA/Dev), the app
  falls back to a persisted local demo session. A real `AuthException` (wrong
  password, unconfirmed email) never falls back.
- **Sign-out** (`AuthProvider.logout`) clears both the Supabase session and the
  offline demo session and returns to the guest home — it never forces `/login`.
