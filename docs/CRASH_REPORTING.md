# Crash reporting & debug logs

How CalcMaster captures errors, and how to get them off a device — during
testing and from the stores after release.

---

## The one thing to understand first

**A Dart exception is not a native crash.** This trips up most Flutter teams.

| What happened | Native process dies? | Appears in Play Console / App Store Connect? |
|---|---|---|
| Native crash (SIGSEGV in a plugin, Impeller, the engine) | Yes | **Yes**, automatically — no SDK needed |
| Android ANR (main thread blocked >5s) | No | **Yes**, Android Vitals only |
| Unhandled **Dart** exception | No — Flutter catches it and paints a red/grey error box | **No.** Invisible to both stores |
| Caught Dart exception | No | **No** |

So the stores give you native crashes and ANRs for free, and tell you nothing
about the failure mode a Flutter app actually has most often. That gap is what
`lib/services/crash_reporter.dart` closes.

---

## What the app captures

`CrashReporter` installs all three Flutter error channels — the app previously
installed **none** of them, so unhandled Dart errors were silently swallowed in
release builds:

| Channel | Catches |
|---|---|
| `FlutterError.onError` | Errors inside the widgets/rendering layer |
| `PlatformDispatcher.instance.onError` | Uncaught async errors |
| `runZonedGuarded` (via `CrashReporter.guard`) | Anything escaping `runApp`'s zone |

Each record stores the error, stack, severity, timestamp and the recent
**breadcrumbs** — the trail that usually makes a stack trace interpretable.
Records are persisted immediately (they must survive the process death that
often follows) and capped at 20, oldest dropped first.

Leave breadcrumbs at meaningful transitions:

```dart
CrashReporter.instance.leaveBreadcrumb('opened /tools/bmi');
```

Report a handled error you still want to see:

```dart
await CrashReporter.instance.recordError(e, stack, library: 'currency');
```

---

## Getting logs off a device

### 1. In-app — works anywhere, no cable

**Settings → Diagnostics** lists captured errors with a **Copy all** button.

This is the only option that works for a TestFlight or internal-testing build
on someone else's phone, where you cannot attach a debugger. Ask the tester to
reproduce, then copy and paste the text back.

### 2. Attached device — the full system log

```bash
# Android — everything, or just this app
adb logcat
adb logcat --pid=$(adb shell pidof -s com.americangroupllc.calcmaster)

# Only Flutter's own output
adb logcat -s flutter

# Crashes and ANRs specifically
adb logcat -b crash
adb shell dumpsys activity anr        # or pull /data/anr/
```

```bash
# Flutter, while running from your machine
flutter run                  # logs stream into the console
flutter logs                 # attach to an already-running app
```

```bash
# iOS — needs macOS
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
# Physical device: Console.app, or Xcode → Window → Devices and Simulators
```

### 3. Symbolicating a release stack trace

Release builds are obfuscated, so a raw trace is unreadable. Build with split
debug info **and keep the symbols** — you cannot symbolicate without them:

```bash
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols

flutter symbolize -i stack_trace.txt -d build/symbols/app.android-arm64.symbols
```

> Archive `build/symbols/` per release. Losing it makes every crash report from
> that build permanently unreadable.

---

## Collecting from the stores after release

### Google Play Console

**Quality → Android vitals → Crashes and ANRs.** Native crashes and ANRs, with
stack traces, device/OS breakdown, and the affected app version. Retention is
limited, so export anything you need to keep.

- Deobfuscation: upload the R8 mapping file at
  `build/app/outputs/mapping/release/mapping.txt`. Play accepts it inside the
  AAB automatically, but confirm it is present or traces stay obfuscated.
- `adb bugreport` from a tester's device gives the full picture for one incident.

### Apple App Store Connect

**Xcode → Window → Organizer → Crashes**, or App Store Connect →
your app → **Trends / Metrics**.

- Only from users who opted into sharing diagnostics, so volume under-reports.
- Upload the dSYM, or traces are unsymbolicated. If bitcode-recompiled, download
  Apple's dSYMs from Organizer.
- TestFlight crashes appear here too, usually faster than production.

**Both stores only report native crashes and ANRs** — see the table at the top.

---

## Attaching Crashlytics or Sentry

`CrashReporter` deliberately ships with **no** third-party SDK: Crashlytics
needs `google-services.json` (Android) and `GoogleService-Info.plist` (iOS),
neither of which is in this repo. Adding `firebase_crashlytics` without them
**fails the Android build** — the `google-services` Gradle plugin errors out.

The capture layer works without any of that. To add a vendor later, implement
one interface — no call site changes:

```dart
class CrashlyticsSink implements CrashSink {
  @override
  Future<void> report(CrashRecord record) =>
      FirebaseCrashlytics.instance.recordError(
        record.error,
        StackTrace.fromString(record.stack),
        fatal: record.fatal,
        information: record.breadcrumbs,
      );
}

// in main(), after Firebase.initializeApp():
CrashReporter.instance.sink = CrashlyticsSink();
```

Steps to enable Crashlytics:

1. Create the Firebase project; add both apps using bundle id
   `com.americangroupllc.calcmaster`.
2. Add `google-services.json` → `android/app/`, `GoogleService-Info.plist` →
   `ios/Runner/` (and to the Xcode target).
3. Add `firebase_core` + `firebase_crashlytics` to `pubspec.yaml`, and the
   `com.google.gms.google-services` / `com.google.firebase.crashlytics` Gradle
   plugins.
4. Set the sink as above.
5. Verify with a deliberate test crash, confirm it lands in the console, then
   remove it.

A failing sink can never mask the original error — `recordError` swallows sink
exceptions and still persists the record. There is a test for exactly that.

---

## Privacy

Diagnostics stay **on the device** until a sink is attached. If you attach one,
update `ios/Runner/PrivacyInfo.xcprivacy` and both stores' privacy
questionnaires — crash logs and device identifiers become collected data, and
Crashlytics ships its own privacy manifest whose declarations are additional to
yours. See [PRODUCTION.md](../PRODUCTION.md).
