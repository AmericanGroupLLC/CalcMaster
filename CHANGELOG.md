# Changelog

All notable changes to CalcMaster are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Crash capture.** The app installed *none* of Flutter's three error channels, so any unhandled Dart error was silently swallowed in release. `CrashReporter` now installs `FlutterError.onError`, `PlatformDispatcher.onError` and a guarded zone, persists records with breadcrumbs across process death, and forwards to an optional `CrashSink` (Crashlytics/Sentry/backend) — with no third-party SDK or credentials required.
- **Settings → Diagnostics** screen: view and copy captured errors from a device you cannot attach a debugger to (TestFlight/internal testing).
- [docs/CRASH_REPORTING.md](docs/CRASH_REPORTING.md) — collecting logs from Play Console Android Vitals and App Store Connect, `adb`/`flutter logs`/Console.app during testing, release symbolication, and how to attach Crashlytics.
- `marketing/site/app-ads.txt` declaring AdMob publisher `pub-8528784688453695` (AMERICAN GROUP LLC), plus a test keeping it in sync with `MonetizationConfig.admobPublisherId`.
- Ad IDs are now checked for **ownership**, not just for being non-test: a unit belonging to any other publisher account is refused, so ad revenue cannot accrue to the wrong account. Both platforms currently fail this check, so no ads serve until real IDs for `pub-8528784688453695` are configured.
- iOS App Store privacy manifest (`ios/Runner/PrivacyInfo.xcprivacy`), registered in the Runner target's Resources build phase.
- Server-side store-receipt verification (`ApiClient.verifyReceipt`), configured via `--dart-define=RECEIPT_VERIFICATION_PATH`.
- CI now runs `flutter analyze`, `flutter test`, an Android release App Bundle build, and an unsigned iOS build.
- Regression tests for signed exponents, factorial bounds, the ad-serving guard, and ATT consent.

### Removed
- Four unreferenced scaffold leftovers: `.gitignore.tmpl.new`, `README.md.tmpl.new`, `analysis_options.yaml.tmpl.new`, `pubspec.dev_dependencies.yaml` (the last suggested packages the project does not use).
- The repository is now **Flutter, iOS + Android only**. Deleted the two React Native/Expo clients (`legacy-react-native/`, `mobile-rn/`), the browser extension, the Electron desktop wrapper, the NestJS backend, the Flutter `web/` target, the TypeScript/Jest suite, and the Node/Expo tooling (`package.json`, `tsconfig.json`, `jest.config.js`, `app.json`, `eas.json`, `docker-compose.yml`, `.env.example`) — 210 files. See [TRIAGE.md](TRIAGE.md).
- Dropped the web build from `release.yml`, `tools/release_all.sh`, and the `webapp` Firebase hosting target; the `marketing` hosting target and Pages workflow stay, since the stores require a reachable Privacy Policy URL.

### Changed
- The iOS ATT prompt is now requested before the first ad request. `TrackingService` existed but was never called from anywhere, so the prompt never appeared and AdMob was capped to non-personalised ads.
- `InAppPurchase.instance` is resolved lazily, so no store connection is opened while subscriptions are disabled.
- RevenueCat keys documented as unused — purchases run through `in_app_purchase`.

### Fixed
- The calculator keypad shifted vertically while typing: the live `= result` line was rendered only when the expression was currently valid, so the keypad jumped on `2`, back on `2^`, and again on `2^-3`. On a calculator a mis-tap is a wrong answer. The line's height is now reserved unconditionally.
- Negative exponents returned wrong results: `2^-3` evaluated to `1.5` instead of `0.125`. Unary minus is now a real prefix operator instead of `(-1)*` desugaring, so `-2^2 == -4` and `2^-3 == 0.125` both hold.
- `!` on a large operand (e.g. `1e15!`) looped past double overflow and froze the UI isolate; it now short-circuits above 170.
- Malformed numbers such as `1.2.3` escaped as `FormatException` instead of `CalcError`.
- The `adsEnabled` master switch was inoperative: `AdService.enabled` fell back to "a unit-ID string is non-empty", which is always true, so ads could not be turned off on mobile.
- Removed the literal `com.googleusercontent.apps.REVERSED_CLIENT_ID` placeholder URL scheme from `Info.plist`.

### Security
- Purchases now **fail closed**: an entitlement is granted only on a server's verdict, never on the client-side store callback alone, which is forgeable on a compromised device.
- Release builds refuse to serve Google's sample ad inventory, which earns nothing and breaches AdMob policy when shown to real users.

## [0.1.0] - May 26, 2026

### Added
- Initial repository scaffold
- Test infrastructure (unit + component + integration + E2E)
- CI pipeline with ≥90% line / ≥85% branch coverage gate
- Documentation set: README, DESIGN, SPEC, RELEASE, TESTING, CONTRIBUTING

[Unreleased]: https://github.com/AmericanGroupLLC/CalMaster/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/AmericanGroupLLC/CalMaster/releases/tag/v0.1.0
