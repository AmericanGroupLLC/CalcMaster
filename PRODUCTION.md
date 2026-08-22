# CalcMaster — Production Release Guide (iOS + Android)

CalcMaster is a **Flutter** app (`pubspec.yaml`, `lib/`) targeting **iOS and
Android only**. The previous version of this file described an
`npm install && npm run build` Node deployment, left over from a retired React
Native implementation that has since been removed from the repository along with
the Expo, Electron, browser-extension, NestJS-backend and Flutter-web trees.

| | |
|---|---|
| Bundle / application id | `com.americangroupllc.calcmaster` |
| Version | `4.0.0+1` (`pubspec.yaml`) |
| Flutter SDK | 3.44.8 stable (Dart 3.12.2) |
| Platforms | iOS, Android (only) |

---

## Build

```bash
flutter pub get
flutter analyze --no-fatal-infos   # info lints are pre-existing/intentional
flutter test

flutter build appbundle --release  # Android → build/app/outputs/bundle/release/
flutter build ios --release        # iOS   → requires macOS + Xcode
```

> **Do not run other `flutter` commands while a release build is in progress.**
> A concurrent `flutter test`/`pub get` rewrites
> `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`
> to include dev-dependency plugins (`integration_test`,
> `flutter_native_splash`). The release build then compiles that file and fails
> with `package dev.flutter.plugins.integration_test does not exist`. If you hit
> it, `flutter clean && flutter pub get` and rebuild without anything else running.

---

## Release blockers

These must be resolved before shipping. Each is blocked on a credential or
account this repository intentionally does not contain.

### Android

| Item | Status | Action |
|---|---|---|
| Release signing | ⛔ **Blocker** | `android/key.properties` is absent (gitignored), so `flutter build appbundle --release` **falls back to the debug keystore** — the bundle built here is signed `CN=Android Debug`, which Play Console rejects. Create the keystore and `key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). The Gradle config warns loudly on this fallback, but note `flutter build` swallows all Gradle console output — the warning is only visible under a direct Gradle/fastlane invocation. |
| AdMob IDs | ⛔ **No ads serve** | Every Android ID belongs to publisher `1804742004018995`, not the app's account `pub-8528784688453695` (AMERICAN GROUP LLC). Serving them would earn into the other account, so `androidAdIdsAreReal` is false and `AdService` declines. Create the app under `pub-8528784688453695` and paste its app ID + unit IDs. |
| `app-ads.txt` | ⚠️ Needs hosting | `marketing/site/app-ads.txt` declares `pub-8528784688453695`. It must be live at `https://safecodeg.com/app-ads.txt` **and** that domain must be the developer website in both store listings, or AdMob treats the inventory as unauthorized and demand drops. |
| `google-services.json` | ℹ️ Not required | Firebase (analytics/FCM) is disabled. Required only if `analyticsEnabled`/`fcmEnabled` are turned on. |

### iOS

| Item | Status | Action |
|---|---|---|
| Privacy manifest | ✅ Added | `ios/Runner/PrivacyInfo.xcprivacy`, registered in the Runner target's Resources phase. Declares ATT tracking and the `NSPrivacyAccessedAPICategoryUserDefaults` / `1C8F.1` required-reason API. |
| AdMob app + unit IDs | ⛔ Ads stay off | `GADApplicationIdentifier` (`Info.plist`) and `admobIos*` (`monetization_config.dart`) are Google's **public sample IDs**. `AdService` deliberately serves no ads on iOS release builds until real IDs land, rather than showing sample inventory to real users. |
| `SKAdNetworkItems` | ⛔ With iOS ads | Not present in `Info.plist`. Add Google's published AdMob SKAdNetwork identifier list at the same time as the real ad IDs, or iOS ad attribution is lost. |
| Google Sign-In | ⚠️ Non-functional on iOS | Needs `GoogleService-Info.plist` in `ios/Runner/` plus a `CFBundleURLSchemes` entry for its `REVERSED_CLIENT_ID`. Fails gracefully today; email/password, Apple Sign-In and guest mode are unaffected. |
| Signing / provisioning | ⛔ **Blocker** | Configure the Apple Developer team and distribution profile in Xcode. |

### Both

| Item | Status | Action |
|---|---|---|
| Subscriptions | ⛔ Disabled by design | `subscriptionsEnabled = false`. `PremiumProvider` **fails closed**: it grants Pro only when a backend validates the store receipt. Before enabling, deploy a receipt-verification endpoint and set `--dart-define=RECEIPT_VERIFICATION_PATH=...`. Granting on the client-side store callback alone is forgeable. |
| Store listing URLs | ⚠️ | `appStoreUrl` still contains the `id0000000000` placeholder. Update after the listing exists. |

---

## Verification status

`flutter analyze` (0 errors/warnings) and `flutter test` were run on Linux and
pass. **The iOS build has not been verified** — it requires macOS with Xcode,
which is not available in the development environment used here. The
`build-ios` job in `.github/workflows/ci.yml` runs
`flutter build ios --release --no-codesign` on `macos-latest` and asserts the
privacy manifest is bundled; treat its first green run as the iOS build
verification.
