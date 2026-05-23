# CalcMaster · App Store Marketing Assets

This folder holds the screenshots Apple requires for App Store Connect submission.

## What's in here today

```
marketing/screenshots/
├── iphone-6.1-convert-home.png    (1206 × 2622)  Convert tab home — hero shot
├── iphone-6.1-calculate-hub.png   (1206 × 2622)  Calculate hub with 5 tiles
├── iphone-6.1-finance-hub.png     (1206 × 2622)  Finance hub with 7 tiles
├── iphone-6.1-tools-hub.png       (1206 × 2622)  Tools hub with 8 tiles
├── iphone-6.1-settings.png        (1206 × 2622)  Settings screen
└── iphone-6.1-paywall.png         (1206 × 2622)  Pro paywall (3 tiers)
```

These were captured from the **iPhone 17 simulator (6.1")** running the production debug build of CalcMaster. They're ready to upload to App Store Connect under the "iPhone 6.1" Display" media set.

## Apple's required device classes

App Store Connect (as of late 2025) requires screenshots in *at least one* of these classes:

| Class | Native pixel size | Example device | Status |
|---|---|---|---|
| **6.9"** | 1320 × 2868 | iPhone 17 Pro Max | ⚠️ Not yet captured (see below) |
| **6.7"** | 1290 × 2796 | iPhone 16 Pro Max / 15 Pro Max | ❌ Need to install older simulator runtime |
| **6.5"** | 1242 × 2688 / 1284 × 2778 | iPhone 11 Pro Max / 14 Plus | ❌ Need to install older simulator runtime |
| **6.1"** | 1206 × 2622 | iPhone 17 / 16 / 15 | ✅ Captured |
| **5.5"** | 1242 × 2208 | iPhone 8 Plus | ❌ Optional, needs iOS 16 runtime |

> **Apple's rule of thumb:** uploading the largest size your app supports is enough — App Store Connect will down-scale for smaller devices automatically. Today the **6.9"** set is the marquee requirement.

## How to (re)generate

### Quick — same screens, different device

A reusable script lives at `tools/capture_marketing_shots.sh`. To capture from any booted simulator:

```bash
# Boot the device class you want first, then…
./tools/capture_marketing_shots.sh
```

Edit the script's UDID variables (`PRO_MAX`, `P17`, etc.) to point at the simulators you have booted.

### How the script works

1. Patches `lib/app_router.dart` `initialLocation` to each of `/convert`, `/calculate`, `/finance`, `/tools`, `/settings`, `/paywall`.
2. Runs `flutter build ios --simulator --debug` (≈15s incrementally).
3. Installs the rebuilt `Runner.app` on every UDID listed.
4. Launches the app, waits for splash → first frame, then `xcrun simctl io <udid> screenshot ...`.
5. Restores the original `initialLocation: '/convert'`.

### To get the missing 6.9" Pro Max screenshots

The iPhone 17 Pro Max (6.9", required for App Store) had a stuck system "Allow widgets from Maps to use your location?" dialog blocking every screenshot during this run. To fix:

1. Open the iPhone 17 Pro Max simulator window.
2. Tap **Don't Allow** (or Allow — your choice) on the dialog.
3. Re-run `./tools/capture_marketing_shots.sh`.

The 6 PNGs at 1320 × 2868 will land in this folder.

### To get 6.5" / 5.5" screenshots

Apple removed older iPhone runtimes from new Xcode installs. Bring them back:

1. Xcode → Settings → Components.
2. Download **iOS 16.4 Simulator** (gives you iPhone 14 Plus → 6.5").
3. Download **iOS 15.5 Simulator** (gives you iPhone 8 Plus → 5.5").
4. Boot the device, edit the UDIDs in the capture script, re-run.

## Upload to App Store Connect

1. https://appstoreconnect.apple.com → My Apps → CalcMaster → Distribution → App Store → iOS App.
2. Scroll to **App Previews and Screenshots** and pick the device class that matches each PNG name.
3. Drag the PNGs from this folder. Apple validates pixel dimensions on upload — if a file is the wrong size it'll reject it with a clear error.
4. Add a 1-3 line caption per screenshot (Apple shows these alongside the image on the listing).

### Suggested captions

| File | Caption |
|---|---|
| `iphone-6.1-convert-home.png` | "10 unit categories. Tap any one to convert instantly." |
| `iphone-6.1-calculate-hub.png` | "Standard, Scientific, Percentage, Base + Fraction calculators." |
| `iphone-6.1-finance-hub.png` | "Tax, Tip, Loans, Currency, Compound Interest — region-aware." |
| `iphone-6.1-tools-hub.png` | "GPS, Ohm's Law, BMI, Time Zones and 4 more utilities." |
| `iphone-6.1-settings.png` | "Subscribe to Pro, restore purchases, and tune notifications." |
| `iphone-6.1-paywall.png` | "Unlock Pro: ad-free, advanced insights, real-time rates." |

## Play Store

For Google Play, screenshots can be any 16:9 or 9:16 aspect ratio between 320–3840px. The same iPhone PNGs work — Play accepts iOS shots in the listing because the marketing image's aspect ratio is what matters, not the device frame.

You'll *additionally* need:
- **Feature graphic**: 1024 × 500 PNG/JPG (banner shown at the top of the listing)
- **High-res icon**: 512 × 512 PNG (Play uses this in search; CalcMaster's `assets/icon/app_icon.png` at 1024×1024 down-scales to this)
