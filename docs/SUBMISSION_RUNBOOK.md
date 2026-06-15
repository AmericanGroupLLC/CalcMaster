# CalcMaster · App Store Submission Runbook

> ⚠️ **For the live launch steps + exact account values, use `docs/GO_LIVE.md` (canonical).**
> This file is the field-by-field reference map; some status notes below predate the
> automation (screenshots are now auto-uploaded via Fastlane, the domain is owned, etc.).

A field-by-field map of everything the App Store and Play Store ask for, where each
value comes from in this repo, and what is genuinely blocked on external accounts.

Last reconciled: 2026-06-14 (against pubspec `4.0.0+1`, bundle `com.americangroupllc.calcmaster`).

---

## 0. App identity (single source of truth)

| Field | Value | Where it lives |
|---|---|---|
| On-device name | `CalcMaster` | `ios/Runner/Info.plist` (CFBundleDisplayName/Name), `android/app/src/main/AndroidManifest.xml` (`android:label`), `lib/main.dart` (`MaterialApp.title`) |
| Store listing title | `CalcMaster` (App Store) / `CalcMaster — World Calculator` (Play) | `marketing/listing-copy.md` (paste into dashboards) |
| Bundle / package ID | `com.americangroupllc.calcmaster` | `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`), `android/app/build.gradle.kts` (`applicationId`) |
| Version name | `4.0.0` | `pubspec.yaml` `version:` → feeds `FLUTTER_BUILD_NAME` (iOS) + `flutter.versionName` (Android) |
| Build number | `1` | `pubspec.yaml` `+1` → feeds `FLUTTER_BUILD_NUMBER` / `flutter.versionCode` |

> To bump for the next release, change **only** `pubspec.yaml` `version: X.Y.Z+N`. Both platforms read from it.
> `app.json` is legacy Expo/React-Native config (the live app is Flutter); its identity fields have been aligned for consistency but it is not used by the Flutter build.

---

## 1. Apple App Store — field → source

| App Store Connect field | Value / source | Status |
|---|---|---|
| App name | `marketing/listing-copy.md` §2 | ✅ ready |
| Subtitle | §2 | ✅ ready |
| Promotional text | §2 | ✅ ready |
| Description | §2 | ✅ ready |
| Keywords | §2 | ✅ ready |
| Category (primary/secondary) | Utilities / Productivity | ✅ ready |
| Support URL | `https://www.safecodeg.com/calcmaster/support.html` | ⚠️ page exists (`marketing/site/support.html`), **needs hosting** |
| Marketing URL | `https://www.safecodeg.com` | ⚠️ needs hosting |
| Privacy Policy URL | `https://www.safecodeg.com/calcmaster/privacy.html` | ⚠️ page exists (`marketing/site/privacy.html`), **needs hosting** — REQUIRED |
| App icon 1024×1024 | `Assets.xcassets/AppIcon.appiconset` (from `assets/icon/app_icon.png`) | ✅ ready |
| iPhone screenshots | `marketing/screenshots/iphone-6.9-*.png` | ⚠️ exist, but show old "CalcMaster" brand — **re-capture after rename** |
| App Privacy ("nutrition label") | answers in `listing-copy.md` §3 questionnaire | 🔲 enter in dashboard |
| Age rating | 4+ | ✅ ready |
| Review notes | `listing-copy.md` §4 | ✅ ready |
| Test account | N/A — no login (stated in review notes) | ✅ n/a |
| **Production IPA** | `flutter build ipa` | ❌ **blocked** — needs Apple Developer Program + signing (see §3) |
| In-app purchases | 3 tiers, `lib/monetization/monetization_config.dart` | 🔲 configure products in App Store Connect |

## 2. Google Play Store — field → source

| Play Console field | Value / source | Status |
|---|---|---|
| App name | `marketing/listing-copy.md` §3 | ✅ ready |
| Short description | §3 | ✅ ready |
| Full description | §2 body | ✅ ready |
| App category | Tools (primary) | ✅ ready |
| Contact email | `support@safecodeg.com` | ⚠️ needs a real mailbox |
| Website | `https://www.safecodeg.com` | ⚠️ needs hosting |
| App icon 512×512 | `assets/icon/app_icon.png` (1024 down-scales) | ✅ ready |
| Feature graphic 1024×500 | `marketing/play-store/feature-graphic-1024x500.png` | ⚠️ verify no old brand text |
| Phone screenshots | `marketing/screenshots/*.png` | ⚠️ re-capture after rename |
| Privacy Policy URL | `https://www.safecodeg.com/calcmaster/privacy.html` | ⚠️ needs hosting — REQUIRED |
| Data safety form | answers in `listing-copy.md` §3 | 🔲 enter in dashboard |
| Content rating questionnaire | `listing-copy.md` §3 | ✅ answers drafted |
| Release notes | `listing-copy.md` §3 "What's new" | ✅ ready |
| **Signed AAB** | `build/app/outputs/bundle/release/app-release.aab` | ⚠️ builds, but **re-sign with a real upload key** (see §3) |
| In-app purchases / subscriptions | 3 tiers | 🔲 configure in Play Console |

---

## 3. Hard blockers (cannot be completed inside this repo)

These require you to hold external accounts / secrets:

1. **Apple Developer Program** — $99/yr enrollment, then create a Distribution
   certificate + App Store provisioning profile for `com.americangroupllc.calcmaster`.
   Only then does `flutter build ipa` produce an uploadable `.ipa`.
   Full command sequence: `docs/RELEASE.md` → "iOS release".

2. **Android upload key** — the current keystore uses a throwaway password
   (`calcmaster-upload`). Generate a real key, store the password in a secret
   manager, and **back the keystore up permanently** — losing it means you can
   never ship updates under the same package name. See `docs/RELEASE.md` → "Android signing".

3. **Public hosting + domain** — buy `www.safecodeg.com` (or any host) and publish
   `marketing/site/*` so the Privacy Policy / Terms / Support URLs resolve. Both
   stores reject submissions with a dead Privacy Policy URL. After hosting, update
   the four `*Url`/`supportEmail` constants in
   `lib/monetization/monetization_config.dart`.

4. **Real support mailbox** — `support@safecodeg.com` must receive mail (Apple's
   reviewer and users will use it).

5. **AdMob + IAP product setup** — create the ad units and the three subscription
   products in each store console, then drop the real IDs into
   `lib/monetization/monetization_config.dart` (currently test IDs).

---

## 4. Pre-submission to-do (in order)

1. Decide/confirm final brand → done: brand is `CalcMaster` everywhere (on-device name, store listing, marketing).
2. Buy domain + host `marketing/site/` → get live Privacy/Terms/Support URLs.
3. Update URLs + support email in `lib/monetization/monetization_config.dart`.
4. Re-capture screenshots from the renamed build (6.9" set is the must-have).
5. Apple: enroll, set signing in Xcode, `flutter build ipa`, upload via Transporter/altool.
6. Android: create real upload key, `flutter build appbundle`, upload AAB.
7. Configure IAP products + AdMob units in both consoles; paste real IDs into config.
8. Fill store listings from `marketing/listing-copy.md`; complete App Privacy / Data Safety forms.
9. Submit for review.
