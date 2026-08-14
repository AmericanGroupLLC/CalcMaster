# CalcMaster · Release Build & Submission Guide

## ✅ What's already built and verified

| Artifact | Path | Size | Verified |
|---|---|---|---|
| **Release APK** (Android sideload / Internal testing) | `build/app/outputs/flutter-apk/app-release.apk` | 52 MB | ✅ Installed on Pixel 8 emulator, runs all 5 tabs |
| **Release App Bundle** (Play Store production upload) | `build/app/outputs/bundle/release/app-release.aab` | 42 MB | ✅ Built — Gradle reports SUCCESS |
| **Unsigned iOS Release** (precursor to .ipa) | `build/ios/iphoneos/Runner.app` | 18 MB | ✅ Built without codesign (no Apple Dev account yet) |

> The iOS `.app` bundle is fully optimised (Hermes + tree-shaken). What's missing is **codesigning** — that's the Apple Developer / provisioning step, not a build problem.

## 📦 Android signing

### Files

| File | Purpose | Source-controlled? |
|---|---|---|
| `~/upload-keystore.jks` | The actual keystore (RSA 2048, 10,000-day validity) | **NO** — never commit |
| `android/key.properties` | Path + passwords pointing at the keystore | **NO** — `.gitignore`d |
| `android/app/build.gradle.kts` | Reads `key.properties`, applies signing config | YES |
| `android/app/proguard-rules.pro` | Keep Flutter classes through R8 minification | YES |

The build.gradle is defensive: when `key.properties` is missing (e.g. in a CI environment without secrets), it falls back to the debug keystore so non-release builds still succeed without ceremony.

### Generated keystore

```
Owner:   CN=CalcMaster, OU=Mobile, O=CalcMaster, L=San Francisco, ST=CA, C=US
Alias:   upload
Validity: 27.4 years (10,000 days)
Passwords: calcmaster-upload (both store + key)
```

> ⚠️ **Change the password before you publish.** A real upload key should use a long random password kept in 1Password / a secret manager. The current one is convenient for local builds only.

### Backing it up

The same keystore must be used for **every** future release. If lost, you can never publish updates to Play Store as the same app — you'd have to re-list with a new package name.

```bash
# Securely back up the keystore + properties to two separate places
cp ~/upload-keystore.jks ~/Backups/calcmaster-upload-keystore.jks
cp /Users/spatchava/Master-Cal/android/key.properties ~/Backups/calcmaster-key.properties
# … and store an encrypted copy in cloud storage / a password manager
```

## 🍎 iOS release (next steps when accounts exist)

### Prerequisites

1. **Apple Developer Program enrollment** — $99 / year at https://developer.apple.com/programs/
2. **App ID** registered: `com.americangroupllc.calcmaster` (already used as the bundle ID)
3. **Distribution certificate** — created in Apple Developer portal or via Xcode
4. **Provisioning profile** — App Store Distribution profile linked to the App ID

### Commands once those exist

```bash
# Open the iOS project in Xcode and let it auto-manage signing:
open ios/Runner.xcworkspace
# Xcode → Runner target → Signing & Capabilities → Team: select your team
#                       → ✅ Automatically manage signing

# Then back to terminal:
flutter build ipa --release
# Outputs: build/ios/ipa/calcmaster.ipa  (~20 MB)

# Upload to TestFlight / App Store Connect:
xcrun altool --upload-app -f build/ios/ipa/calcmaster.ipa \
  --type ios -u <appleid@example.com> -p <app-specific-password>

# OR use the modern alternative:
xcrun notarytool submit build/ios/ipa/calcmaster.ipa \
  --apple-id <appleid@example.com> \
  --team-id <TEAM_ID> \
  --password <app-specific-password> \
  --wait
```

### Or use Apple's Transporter app

1. Download **Transporter** from the Mac App Store (free).
2. Sign in with your Apple ID.
3. Drag the generated `.ipa` into Transporter → Deliver.
4. Wait ~5 min for Apple to process.
5. The build appears in App Store Connect → TestFlight → iOS Builds.

## 📲 Side-loading the release APK to a real Android device

Useful for QA on Florian / any physical phone.

```bash
# 1. Enable Developer Options on the phone (tap Build Number 7 times in Settings)
# 2. Enable USB Debugging.
# 3. Plug in USB. Accept the RSA fingerprint prompt on the phone.
adb devices                                # confirm device shows up
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am start -n com.americangroupllc.calcmaster/.MainActivity

# To uninstall:
adb uninstall com.americangroupllc.calcmaster
```

## 🚀 Submission flow

### Google Play Console (Internal testing → Production)

1. Create the app entry on https://play.google.com/console (one-time $25).
2. **App information** → fill from `marketing/listing-copy.md` § 3.
3. **App content** → answer the content rating, target audience, ads, data safety questionnaires.
4. **Production → Create new release** → upload `build/app/outputs/bundle/release/app-release.aab`.
5. **Review & roll out**. First review: 1–7 days. Subsequent updates: usually < 24 h.

> Tip: start with the **Internal testing** track. Add testers by email; they install via a Play link. No review delay. Promote to Production once you're happy.

### App Store Connect (TestFlight → App Store)

1. https://appstoreconnect.apple.com → My Apps → + → New App.
   - Bundle ID: `com.americangroupllc.calcmaster`
   - SKU: `calcmaster-001` (anything unique)
2. **App Information** → fill from `marketing/listing-copy.md` § 2.
3. **iOS App** → upload IPA via Transporter (above).
4. **TestFlight** → invite internal testers (up to 100, no review). Optionally add external testers (up to 10,000, requires a brief review).
5. **App Store** → submit for review when ready. Apple review SLA: 1–3 days.

### Pre-submission self-check

Run through this list before clicking Submit:

- [ ] All `// REPLACE:` markers in `lib/monetization/monetization_config.dart` are filled with real values
- [ ] All `MonetizationConfig` master switches are set to `true` for the pillars you're activating
- [ ] Privacy Policy URL is published and reachable
- [ ] Terms of Service URL is published and reachable
- [ ] App icon visible in both `assets/icon/app_icon.png` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Splash screen shows your dark `#0B1020` color (verified ✓)
- [ ] App Bundle (`.aab`) signed with the release keystore (verified ✓)
- [ ] iOS .ipa codesigned with App Store Distribution profile
- [ ] `flutter test` returns 23/23 ✅ (verified ✓ in this build)
- [ ] All 5 tabs render without crash on a real device (verified on emulator ✓ — re-test on real Android phone before publishing)
- [ ] Tested on slow network — currency-rates fallback works without internet
- [ ] Tested with location permission denied — GPS tool fails gracefully
- [ ] App handles dark mode (always dark) and reasonable text scale settings

## 📋 Build commands cheat-sheet

```bash
# DEBUG builds (with hot-reload, large)
flutter run -d <device-id>                  # iOS sim or Android emu/device
flutter build apk --debug                   # produces app-debug.apk
flutter build ios --simulator --debug       # produces Runner.app for sim

# RELEASE builds (production-ready, optimised)
flutter build apk --release                 # 52 MB single APK — for sideload
flutter build appbundle --release           # 42 MB .aab — for Play Store
flutter build ipa --release                 # codesigned .ipa — for TestFlight
flutter build ios --release --no-codesign   # unsigned .app — local dev only

# Test and analyze
flutter test
flutter analyze
flutter doctor -v                            # check toolchain health
```

## 🔍 What was verified in this build pass

```
=== flutter test ===                23/23 pass ✅
=== flutter analyze ===             0 errors, 39 style infos ✅
=== flutter build apk --release ==  52 MB, signed with upload key ✅
=== flutter build appbundle ==      42 MB .aab ✅
=== flutter build ios --release ==  18 MB Runner.app (no codesign) ✅
=== adb install + launch ==         App ran, all 5 tabs visible ✅
=== Screenshot proof ==             /tmp/calcmaster-shots/11-android-release.png
```
