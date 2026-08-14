# CalcMaster

> **A futuristic AI-styled world calculator and converter** — iOS, Android, Web, and a
> deployable marketing site. 12 languages, 11 regions with real tax brackets, runs offline.

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-proprietary-red)](#)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20Web-lightgrey)](#)

---

## Quick start

```bash
git clone <this-repo>
cd Master-Cal
flutter pub get
flutter run -d <device-id>            # iOS sim, Android emu/device, or chrome
```

Run tests:
```bash
flutter test                          # 35+ tests, all platforms
```

Build everything in one command:
```bash
./tools/release_all.sh                # produces dist/{android,ios,web,site}
```

---

## What's in here

```
Master-Cal/
├── lib/                                  Dart source — the app
│   ├── main.dart                         App entry, providers, MaterialApp.router
│   ├── app_router.dart                   go_router with splash → tabs → modals
│   ├── theme/tokens.dart                 Colors, radii, spacing, typography
│   ├── state/                            RegionProvider, NotesProvider
│   ├── monetization/                     Single-file config + 5 service stubs
│   │   └── monetization_config.dart      ⭐ ALL CREDENTIALS LIVE HERE
│   ├── lib_units.dart                    10 conversion categories with full unit math
│   ├── lib_currency.dart                 11 regions + ECB rate fetcher (Frankfurter API)
│   ├── lib_tax.dart                      Real 2025-26 income tax brackets per region
│   ├── lib_calc.dart                     Shunting-yard expression parser
│   ├── lib_format.dart                   Locale-aware number/currency/percent formatters
│   ├── i18n_helpers.dart                 Category id → localized label mapper
│   ├── l10n/                             ARB files (12 locales)
│   │   ├── app_en.arb (source of truth)
│   │   ├── app_es / zh / hi / fr / ar / de / ja / pt / ko / ru / it (translations)
│   │   └── generated/                    Auto-generated from ARB by gen-l10n
│   ├── screens/
│   │   ├── splash_screen.dart            Animated "i" / "a" → CalcMaster
│   │   ├── convert_home.dart, convert_detail.dart
│   │   ├── calculate/, finance/, tools/  Hub homes + sub-screens
│   │   ├── notes_screen.dart, settings_screen.dart, paywall_screen.dart
│   │   └── privacy_policy_screen.dart, about_screen.dart
│   └── widgets/
│       ├── glass_card.dart               BackdropFilter frosted card
│       ├── glow_text.dart                Text with accent halo
│       ├── animated_gradient_background.dart
│       ├── particle_dot_grid.dart        30 fps subtle backdrop
│       ├── tab_scaffold.dart             5-tab bottom nav
│       ├── inner_scaffold.dart           Detail-page scaffold
│       ├── convert_card.dart, rich_hub_card.dart
│       ├── region_pill.dart, pill_badge.dart, pro_badge.dart
│       ├── number_input.dart, result_row.dart, chip_picker.dart
│       ├── banner_ad_slot.dart, affiliate_cta.dart
│       └── hub_tile.dart, key_pad.dart
├── assets/icons/                         30 hand-authored line-art SVGs
├── assets/icon/                          App-icon master + Android adaptive foreground
├── assets/splash/                        Splash logo master
├── test/                                 Widget + unit tests
├── ios/                                  Xcode workspace (Apple Dev cert needed for IPA)
├── android/                              Gradle project (signed with upload keystore)
├── web/                                  Flutter web platform shell
├── marketing/
│   ├── site/                             4 static HTML pages (privacy/terms/support/index)
│   ├── play-store/feature-graphic-1024x500.png
│   ├── screenshots/                      iOS + Android marketing screenshots
│   └── listing-copy.md                   Apple + Play Store listing text
├── tools/
│   ├── gen_icon.dart                     Generate app icon from CalcMaster logo
│   ├── gen_feature_graphic.dart          Generate Play Store 1024×500
│   ├── capture_marketing_shots.sh        Drive simctl + adb to capture all screens
│   └── release_all.sh                    Build APK + AAB + IPA + Web in one command
├── docs/
│   ├── MONETIZATION.md                   Strategy doc + integration map
│   ├── RELEASE.md                        Submission step-by-step for both stores
│   └── WORLDWIDE_LAUNCH_STATUS.md
├── firebase.json                         Two-target hosting config
├── pubspec.yaml                          Flutter package manifest
├── l10n.yaml                             gen-l10n config
└── legacy-react-native/                  Original RN attempt (archived, not built)
```

---

## 🚨 TEMPORARY VALUES TO REPLACE BEFORE PRODUCTION LAUNCH

Every dummy credential, sample URL, and placeholder lives in **one of these places**.
Replace before submitting to App Store / Play Store / public web hosting.

### `lib/monetization/monetization_config.dart` (THE big one)

| What | Current dummy value | Where to get the real one |
|---|---|---|
| `admobIosBanner` | Google's TEST ID (`ca-app-pub-3940256099942544/...`) — Android is REAL | AdMob console → Apps → CalcMaster iOS → Ad units |
| `admobIosInterstitial` | Google's TEST ID — Android is REAL | Same as above |
| `admobIosNative` / `admobAndroidNative` | Google's TEST IDs (native ads are not implemented — no code renders them) | Same as above |
| `admobAppIdIos` | Currently reuses the Android app ID — AdMob issues one per platform | AdMob console → register an iOS app |
| `revenueCatIosKey` / `revenueCatAndroidKey` | `appl_DUMMY_REPLACE_BEFORE_LAUNCH` / `goog_DUMMY_...` | app.revenuecat.com → Apps → Public API key |
| `productMonthly` / `productAnnual` / `productLifetime` | `calcmaster_pro_monthly` / `_annual` / `_lifetime` | App Store Connect IAP + Play Console subscriptions |
| `priceMonthly` / `priceAnnual` / `priceLifetime` | `$2.99 / month` etc. | Match your store pricing |
| `firebaseProjectId` / `firebaseSenderId` | `calcmaster-DUMMY-12345` / `0123456789` | console.firebase.google.com → Project Settings |
| `amazonAssociatesTagUS` / `_UK` / `_IN` | `calcmaster-20` / `-21` | affiliate-program.amazon.com → Tag |
| `mealKitAffiliateUrl` / `wellnessSubscriptionUrl` | `example.com/affiliate/...?ref=DUMMY` | Real partner tracking URLs |
| `affiliateSlots` | Amazon search URLs | Replace with concrete product detail page URLs |
| `privacyPolicyUrl` / `termsOfServiceUrl` | `safecodeg.com/privacy` `/terms` | Publish at a real domain (Iubenda / Termly / GitHub Pages) |
| `supportEmail` | `contact@safecodeg.com` | A real, monitored mailbox |
| `marketingWebsite` / `appStoreUrl` / `playStoreUrl` | `safecodeg.com` / fake bundle IDs | After buying domain + listing apps |

Master switches at the top of the same file:

| Switch | Current | Note |
|---|---|---|
| `adsEnabled` | `true` | App IDs are real (`pub-8528784688453695`), but the **banner unit IDs are still Google's test units**, so `adsReady` is false and no ads load. Replace `admobIosBanner` + `admobAndroidBanner` and ads turn on automatically. Banner is the only format the app renders — interstitial and native unit IDs exist in config but `showInterstitial()`/`nativeUnitId()` have no call sites. |
| `subscriptionsEnabled` | `true` | All three products exist in App Store Connect and are `READY_TO_SUBMIT`. Purchases use `in_app_purchase` (StoreKit) directly — **not** RevenueCat, so the `revenueCat*` keys below are dead config. |
| `affiliatesEnabled` | `false` | |
| `analyticsEnabled` | `false` | |
| `fcmEnabled` | `false` | |

`adsReady` is the single gate for ad loading and now requires the master
switch **and** real app IDs **and** non-test unit IDs. `AdService.enabled`
previously read `adsEnabled || _hasTestAds()`, where `_hasTestAds()` merely
checked a unit-ID string was non-empty — always true — so ads rendered even
with the master switch off. It now defers to `adsReady`.

**Known debt:** `PremiumProvider` grants the entitlement client-side straight
from the StoreKit callback, which is spoofable. The backend already implements
`verifyReceipt` (`backend/src/subscriptions/subscriptions.service.ts`) and
reads `APPLE_SHARED_SECRET`, but the app does not call it yet.

Flip each to `true` per-pillar **only after you've replaced the relevant credentials**.

### Android signing

| What | Current value | What to do |
|---|---|---|
| `~/upload-keystore.jks` | RSA 2048, 27.4-yr validity, password `calcmaster-upload` | **Rotate the password** to a long random string in 1Password before publishing. Back up keystore in 2 separate physical locations — losing it means inability to update the app on Play Store ever. |
| `android/key.properties` | Plaintext password, gitignored | Re-create on every dev machine; never commit. |

### App identity (verified — do not change)

| What | Value |
|---|---|
| Bundle ID / package name (iOS + Android) | `com.americangroupllc.calcmaster` |
| App Store display name | `CalcMaster: World Calc` |
| App Store Connect app ID | `6781554668` |
| Apple team | American Group LLC — `TLH7Z3G27A` |
| Version | `4.0.0+1` (`pubspec.yaml`) |
| Device family | iPhone only (`TARGETED_DEVICE_FAMILY = 1`) |

The Supabase OAuth redirect scheme derives from the bundle ID — renaming it
breaks sign-in.

### iOS signing

Prerequisites (all already in place for American Group LLC):
- Apple Developer Program enrollment
- Apple Distribution certificate + private key in the login keychain
- App Store Connect API key (see below) — the provisioning profile is fetched
  automatically, so no manual profile step

**Credentials.** Secrets are never committed. `fastlane/Fastfile` defaults the
two non-secret identifiers; only the `.p8` private key must be supplied.

| Purpose | Key ID | File | Where it goes |
|---|---|---|---|
| App Store Connect API (build upload, profiles, review submission) | `UV8NYF9767` | `AuthKey_UV8NYF9767.p8` | `ASC_KEY_CONTENT` (base64) |
| In-app purchase / App Store Server API | `PX7TXTDSHP` | `SubscriptionKey_PX7TXTDSHP.p8` | backend only |
| IAP receipt validation (legacy `verifyReceipt`) | — | shared secret | `APPLE_SHARED_SECRET` (backend env) |

Issuer ID (shared by all keys, not a secret): `ec93cc91-97c2-4b03-860b-697d7ec5d1fb`

**Two ways to build and ship** — see the scripts for full usage:

```bash
# A. API key (fully scripted: build → sign → upload → submit for review)
./tools/ios_appstore_submit.sh /path/to/AuthKey_UV8NYF9767.p8

# B. Xcode automatic signing (no API key; needs an Apple ID in Xcode
#    → Settings → Accounts, plus an app-specific password to upload)
UPLOAD=1 FASTLANE_USER='you@example.com' FASTLANE_PASSWORD='xxxx-xxxx-xxxx-xxxx' \
  ./tools/ios_appstore_submit_xcode.sh
```

Path B archives via `xcodebuild -allowProvisioningUpdates` and forces
`CODE_SIGN_IDENTITY=Apple Distribution`, because the project still carries a
legacy project-level `"iPhone Developer"` that can otherwise resolve to a
development cert on a Release archive.

### Marketing site placeholder URLs

`marketing/site/index.html` currently links to:
- `https://apps.apple.com/app/calcmaster` (replace with real App Store URL after listing)
- `https://play.google.com/store/apps/details?id=com.americangroupllc.calcmaster` (replace after Play listing)

`marketing/site/privacy.html` and `terms.html` reference the company name "CalcMaster Inc." in section 5 — replace with your registered legal entity name.

### Firebase Hosting

`firebase.json` defines two hosting targets (`marketing` + `webapp`). Before deploy:
```bash
npm install -g firebase-tools
firebase login
firebase init hosting:targets       # Pick your Firebase project
firebase deploy --only hosting:marketing,hosting:webapp
```

### Backend

**There is NO custom backend.** All "server" interactions are:
- Currency rates: `api.frankfurter.app` (free public ECB API, no key needed)
- Subscriptions: Apple StoreKit + Google Play Billing via RevenueCat (managed)
- Analytics: Firebase Analytics (managed)
- Push notifications: Firebase Cloud Messaging (managed)

If you ever need a custom backend (e.g., cross-device notes sync), the recommended path is Firebase Functions or Cloudflare Workers — both keep marginal cost per active user under $0.001.

---

## Build matrix

| Platform | Command | Output | Approx size |
|---|---|---|---|
| iOS Simulator (debug) | `flutter build ios --simulator --debug` | `build/ios/iphonesimulator/Runner.app` | 50 MB |
| iOS Device (signed) | `flutter build ipa --release` | `build/ios/ipa/calcmaster.ipa` | ~20 MB |
| iOS Device (unsigned, internal QA) | `flutter build ios --release --no-codesign` | `build/ios/iphoneos/Runner.app` | 18 MB |
| Android APK (release) | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` | 53 MB |
| Android App Bundle (Play Store) | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` | 43 MB |
| Flutter Web | `flutter build web --release` | `build/web/` | 36 MB |

`./tools/release_all.sh` runs all of these and stages results in `dist/`.

---

## i18n + region coverage

### Languages (12)

| Code | Language | Native name | Status |
|---|---|---|---|
| en | English | English | ✅ source of truth |
| es | Spanish | Español | ✅ |
| zh | Mandarin | 中文 (Simplified) | ✅ |
| hi | Hindi | हिन्दी | ✅ |
| fr | French | Français | ✅ |
| ar | Arabic | العربية (RTL) | ✅ |
| de | German | Deutsch | ✅ |
| ja | Japanese | 日本語 | ✅ |
| pt | Portuguese | Português | ✅ |
| ko | Korean | 한국어 | ✅ NEW |
| ru | Russian | Русский | ✅ NEW |
| it | Italian | Italiano | ✅ NEW |

### Regions (11) with currency, sales tax / VAT, income tax brackets

| Flag | Region | Currency | Sales tax / VAT | Income tax bracket source |
|---|---|---|---|---|
| 🇺🇸 | US | USD | 8.5% (avg) | IRS 2025 (single/joint/head) |
| 🇬🇧 | UK | GBP | 20% | HMRC 2025-26 |
| 🇪🇺 | EU | EUR | 19% (DE default) | Germany 2025 |
| 🇨🇦 | CA | CAD | 13% (HST avg) | CRA federal 2024-25 |
| 🇦🇺 | AU | AUD | 10% (GST) | ATO 2024-25 |
| 🇮🇳 | IN | INR | 18% (GST) | New regime 2024-25 |
| 🇯🇵 | JP | JPY | 10% | NTA 2024 |
| 🇧🇷 | BR | BRL | 17% | Receita Federal 2024-26 NEW |
| 🇲🇽 | MX | MXN | 16% | SAT ISR 2025 NEW |
| 🇰🇷 | KR | KRW | 10% | NTS 2024-25 NEW |
| 🇦🇪 | AE | AED | 5% (VAT) | 0% personal income tax NEW |

> **Tax bracket disclaimer:** these are general personal-income brackets without state/provincial overlays. The app makes this clear in the Tax screen. For legal filing, users should consult a qualified accountant.

---

## Animated splash

On first cold launch, after Dart boots, an animated splash plays for 2 seconds:
- **iOS users** see the letter `i` drop in, shrink, then the wordmark "CalcMaster" cascades letter by letter.
- **Android users** see the letter `a` doing the same.

Configured in `lib/screens/splash_screen.dart`. The leading letter is selected via `Platform.isIOS / Platform.isAndroid`.

---

## Testing

```bash
flutter test
```

| Suite | Coverage |
|---|---|
| `test/locales_test.dart` | All 12 locales render their hub heading; Arabic forces RTL; English is LTR |
| `test/tabs_test.dart` | All 5 bottom-nav tabs render + cycle without exceptions |
| `test/convert_detail_test.dart` | Swap button + math correctness on Convert detail |
| `test/monetization_config_test.dart` | Default flags + dummy values + safety guards |
| `test/premium_provider_test.dart` | Hydration, purchase/restore stubs, paywall renders |

---

## Production-ready checklist

Before clicking "Submit" on App Store Connect or Play Console:

- [ ] All `// REPLACE:` markers in `lib/monetization/monetization_config.dart` are filled
- [ ] All 5 master switches in MonetizationConfig flipped per-pillar to `true`
- [ ] Privacy policy + Terms of Service published at a real, reachable URL
- [ ] Apple Developer enrollment complete, distribution cert generated, provisioning profile linked
- [ ] AdMob account set up + production unit IDs configured
- [ ] RevenueCat account set up + IAP products created in App Store Connect AND Play Console
- [ ] Firebase project linked + `GoogleService-Info.plist` (iOS) and `google-services.json` (Android) replaced
- [ ] `~/upload-keystore.jks` password rotated to a long random string + backed up in 2 places
- [ ] `flutter test` green (35+ tests pass)
- [ ] `./tools/release_all.sh` produces all 4 artifacts cleanly
- [ ] App icon + splash screen + screenshots reviewed by a human (not just the algorithmic generator)
- [ ] Tested on a real iPhone AND a real Android phone (not just simulators)
- [ ] App Store + Play Store listing copy translated to at least the top 5 target locales

---

## License

Proprietary. © 2026 CalcMaster team. All rights reserved.

## Test / reviewer account

CalcMaster runs fully offline (Supabase auth is flag-gated off). A bundled
local test account is available for reviewers and testers. The session is
persisted across launches via `SharedPreferences`.

- **Email:** `test@americangroupllc.com`
- **Password:** `Test1234!`

Sign in from the login screen (shown before the tab shell) either by entering
the credentials above, or with one tap via the **Use test account** button.
Either path lands on the calculator home. Sign out from Settings to return to
the login screen.
