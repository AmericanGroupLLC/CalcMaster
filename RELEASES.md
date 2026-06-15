# CalcMaster · v4.0.0 — Release Notes

**Released**: 2026-05-23
**Tag**: `v4.0.0`
**Branch**: `release`
**Commit**: see latest on `release` branch

---

## ✨ What's in this release

This is the inaugural production release of CalcMaster — a futuristic AI-styled world calculator and converter for **iOS, Android, and Web**.

### Core features

- **Convert** — 10 unit categories: Distance · Volume · Weight · Temperature · Speed · Area · Data Size · Fuel Economy · Pressure · Energy
- **Calculate** — Standard, Scientific (trig/log/√/^/!), Percentage, Base (Bin/Oct/Dec/Hex), Fraction
- **Finance** — Tax (real 2025-26 brackets per region), Tip & Split, Discount, Compound Interest, EMI/Loan, Currency (live ECB rates), Unit Price
- **Tools** — GPS (decimal ↔ DMS with `Use my location`), Ohm's Law solver, BMI, Date Difference, World Time Zones, ADC/DAC, Age, Aspect Ratio
- **Notes** — Search · add · edit · delete; persisted via SharedPreferences

### Worldwide reach

- **12 languages**: English · Español · 中文 (Mandarin Simplified) · हिन्दी · Français · العربية (RTL) · Deutsch · 日本語 · Português · 한국어 · Русский · Italiano
- **11 regions** with currency + sales tax / VAT + 2025-26 income tax brackets:
  🇺🇸 US · 🇬🇧 UK · 🇪🇺 EU · 🇨🇦 Canada · 🇦🇺 Australia · 🇮🇳 India · 🇯🇵 Japan · 🇧🇷 Brazil · 🇲🇽 Mexico · 🇰🇷 South Korea · 🇦🇪 UAE

### Futuristic AI design

- Animated gradient backgrounds (purple → teal cycle)
- Frosted-glass cards (BackdropFilter blur, accent rim glows)
- Particle dot grid pulsing backdrop
- Glow-text on result numbers
- Platform-specific animated splash: **`i`** morphs into "CalcMaster" on iOS, **`a`** does the same on Android

### Real monetization wired

- **AdMob banner + interstitial ads** via `google_mobile_ads` — Google's TEST IDs serve test ads out of the box
- **iOS App Tracking Transparency** prompt with proper deferred-trigger pattern
- Banner anchored above bottom nav, hidden for Pro subscribers
- Counter-based interstitial trigger (every 5th calculator use)
- **Subscription scaffold** (monthly · annual · lifetime) ready for RevenueCat + Apple/Google IAP credentials
- **Single-file `monetization_config.dart`** holds every credential placeholder

---

## 📦 Binary artifacts (attached to this release)

| Platform | File | Size | Use |
|---|---|---|---|
| **Android** (APK) | `CalcMaster-v4.0.0-android.apk` | 55 MB | Sideload to phones for QA / Internal testing |
| **Android** (App Bundle) | `CalcMaster-v4.0.0-android.aab` | 47 MB | **Upload to Google Play Console** |
| **iOS** (unsigned `.app`) | `CalcMaster-v4.0.0-ios-unsigned.tar.gz` | 11 MB | Pre-codesign artifact. Open `ios/Runner.xcworkspace`, configure signing, then `flutter build ipa --release` for App Store |
| **Flutter Web** | `CalcMaster-v4.0.0-web.tar.gz` | 12 MB | Deploy to any static host (Firebase Hosting, GitHub Pages, Netlify) |
| Checksums | `SHA256SUMS.txt` | 391 B | Verify binary integrity |

Verify any download:
```bash
shasum -a 256 -c SHA256SUMS.txt
```

---

## 🚀 Deployment

### Google Play Console
1. https://play.google.com/console → CalcMaster → Production → Create release
2. Upload `CalcMaster-v4.0.0-android.aab`
3. Fill release notes (copy from this file)
4. Roll out → first review 1–7 days

### Apple App Store
1. **Prerequisite**: Apple Developer Program enrollment ($99/yr)
2. Untar the iOS artifact: `tar -xzf CalcMaster-v4.0.0-ios-unsigned.tar.gz`
3. Open `ios/Runner.xcworkspace` in Xcode → Signing & Capabilities → tick "Automatically manage signing" → select Team
4. From the project root: `flutter build ipa --release`
5. Upload via Apple's Transporter app or `xcrun altool --upload-app`
6. TestFlight first; Apple review typically 1–3 days

### Web hosting
```bash
tar -xzf CalcMaster-v4.0.0-web.tar.gz
firebase deploy --only hosting:webapp
# or
netlify deploy --dir=web --prod
```

---

## 🔑 Pre-launch checklist

Before flipping these from test → production, edit `lib/monetization/monetization_config.dart`:

| Pillar | Test default | Production replacement |
|---|---|---|
| AdMob app ID + 6 ad unit IDs | Google's official TEST IDs | Real AdMob unit IDs from console |
| RevenueCat keys | `appl_DUMMY_…` / `goog_DUMMY_…` | From app.revenuecat.com |
| Firebase project ID | `calcmaster-DUMMY-12345` | From console.firebase.google.com |
| Amazon Associates tags (US/UK/IN) | `calcmaster-20` / `-21` | From affiliate-program.amazon.com |
| Privacy / Terms / Support URLs | `www.safecodeg.com/...` | Publish at a real domain |

Then set the master switches in the same file from `false` → `true` per-pillar.

---

## 📊 Verification

```
flutter analyze     →  0 errors (48 style infos, all benign)
flutter test        →  35 / 35 pass
                       (units · calc · tax · swap · 5 tabs · 12 locales · RTL · paywall · monetization config · premium provider)
flutter build apk --release        →  55 MB
flutter build appbundle --release  →  47 MB
flutter build web --release        →  Hermes WASM, 36 MB unpacked
flutter build ios --release        →  30 MB (unsigned, pre-codesign)
```

Live install verified on Pixel 8 Android emulator + iPhone 17 Pro Max iOS Simulator.

---

## 🚧 Known limitations (next release)

- `iphone-6.9-settings.png` marketing screenshot didn't capture (sim went to sleep mid-script). Re-run `tools/capture_marketing_shots.sh` next session.
- `flutter build ipa --release` (signed) requires Apple Developer cert — not in this release artifact.
- Real Firebase / RevenueCat / AdMob production accounts must be created before flipping monetization master switches to `true`.

---

## 📝 Recent commits in this release

```
5d2e19c  Wire REAL google_mobile_ads SDK + ATT prompt
5555176  Futuristic AI redesign + 12 locales + 11 regions + production README
046f9be  Pro ready
```
