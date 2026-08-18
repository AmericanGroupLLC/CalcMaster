# App Review — 4.0.2 (5), after the Guideline 2.1 rejection of 4.0.1 (4)

Apple did not find a bug. The rejection was **Guideline 2.1 – Information
Needed**: they want the App Review Information section filled in and a screen
recording of the app running on a physical device.

## State right now

- App Store version record renamed **4.0.1 → 4.0.2**, state `DEVELOPER_REJECTED`
  (editable). All metadata, screenshots and review notes carried over.
- **Review notes** answer all seven of Apple's items — `tools/update_review_notes.rb`
  is the source of truth, already pushed (`PATCH appStoreReviewDetails` → 200).
- **Code for 4.0.2**: `pubspec.yaml` at `4.0.2+5`, and the paywall now has
  tappable Terms of Use / privacy policy links (Guideline 3.1.2), localized in
  all 12 locales.
- Builds uploaded so far are 4.0.1 (3) and (4). **A 4.0.2 binary still has to be
  built and uploaded** — the marketing version in the binary must match the
  version record.
- The three IAPs are still `READY_TO_SUBMIT` and can only be attached to the
  version in the App Store Connect UI: `POST /v1/subscriptionSubmissions` and
  `POST /v1/inAppPurchaseSubmissions` return
  `409 STATE_ERROR.INVALID_REQUEST_ENTITY_STATE_INVALID` while the app has never
  been approved, and `reviewSubmissionItems` has no `subscription` /
  `inAppPurchaseV2` relationship (`ENTITY_ERROR.RELATIONSHIP.UNKNOWN`).

## 1. Build and upload 4.0.2 (5)

Flutter cannot run from the agent's shell (writes to the SDK cache outside the
project are blocked with `Operation not permitted`), so run this yourself:

```bash
FLUTTER=/Users/spatchava/agl/.flutter-sdk/bin/flutter
$FLUTTER pub get
$FLUTTER gen-l10n            # regenerates lib/l10n/generated (hand-patched meanwhile)
$FLUTTER analyze lib/screens/paywall_screen.dart

export ASC_KEY_CONTENT="$(base64 -i AuthKey_UV8NYF9767.p8 | tr -d '\n')"
fastlane ios release         # build ipa 4.0.2+5, sign, upload; does NOT submit
```

`fastlane ios release` deliberately sets `submit_for_review: false`. Use plain
`fastlane` rather than `bundle exec fastlane` — the bundle has no gems installed
for Ruby 3.3.9 (run `bundle install` first if you prefer bundler; `Gemfile.lock`
is now `BUNDLED WITH 2.5.22`, the old 1.17.2 pin crashes on Ruby 3.3).

Processing takes 5–15 minutes. Then attach the build:

```bash
ruby tools/ios_submit_for_review.rb     # dry run: attaches newest VALID build, lists items
```

Its IAP lines will print `!` — expected, see above.

## 2. Record the demo video (physical device, required)

`SrikanthiPhone16ProMaX` (iPhone 16 Pro Max, iOS 26.6) is paired to this Mac.
Install the 4.0.2 build from TestFlight, connect by cable, then **QuickTime
Player → File → New Movie Recording** with the iPhone as the source (iOS Control
Center screen recording works too).

Record in this order — it must start at launch and cover every item Apple listed:

1. Launch from the Home Screen (splash, then the calculator).
2. **Convert** → tap a category → type a value → show the results.
3. **Calculate** → one calculation on Standard, one on Scientific.
4. **Finance** → Currency (live rates) and Income Tax with a region change.
5. **Tools** → GPS Coordinates → *Use my location* → **show the location
   permission prompt and allow it**.
6. **Notes** → create, edit, delete a note (shows there is no shared UGC).
7. **Settings → Subscribe to Pro** → paywall → tap a product → **show the
   StoreKit sandbox purchase sheet** → complete or cancel → tap *Restore
   purchases* → tap the **Terms of Use** and **Privacy Policy** links.
8. **Settings → Sign in** with `qa@safecodeg.com` / `QATest@2024!` → sign out
   (proves the account is optional).

Under ~5 minutes, no cuts, no voiceover needed.

## 3. Attach the IAPs, reply, submit

1. **App Store** tab → version **4.0.2** → *In-App Purchases and Subscriptions*
   → **+** → select `calcmaster_pro_monthly`, `calcmaster_pro_annual`,
   `calcmaster_pro_lifetime`. If a product shows a warning, open it: all three
   already have an en-US localization, prices and an uploaded review screenshot,
   so the usual remaining cause is the **Paid Applications Agreement** not being
   active (Business → Agreements).
2. In the rejected submission's Resolution Center thread, **Reply to App
   Review**, attach the recording, and paste the text below.
3. **Submit for Review** — the submission should list **4 items**: iOS App 4.0.2
   plus the three products.

> Thank you for the review. We have updated the App Review Information section
> with the requested details and attached a screen recording of build 4.0.2 (5)
> captured on a physical iPhone 16 Pro Max running iOS 26.6. It begins at app
> launch and covers unit conversion, the calculators, the finance and utility
> tools, notes, the location permission prompt, and the complete subscription
> purchase and restore flow.
>
> 1. Screen recording: attached (physical iPhone 16 Pro Max, iOS 26.6).
> 2. Tested on: iPhone 16 Pro Max (iOS 26.6) and iPhone 13 Pro (iOS 26.6)
>    physical devices, plus the iPhone 17 Pro Max simulator on iOS 26. Minimum
>    deployment target is iOS 15.0, iPhone only, portrait.
> 3. CalcMaster is an offline-first calculator, unit converter and everyday
>    finance toolkit — 10 conversion categories, 5 calculators, 7 finance tools,
>    9 utility tools and local notes, all computed on device. It replaces the
>    several single-purpose, network-dependent calculators users otherwise
>    install. Audience: students, travellers, engineers and tradespeople, and
>    general consumers. Rated 4+, with no user-generated content shared between
>    users.
> 4. No account and no sample files are needed — the app opens directly to the
>    calculator. Features are reached from the bottom tab bar (Convert,
>    Calculate, Finance, Tools, Notes); the paywall is at Settings → Subscribe
>    to Pro; location is requested only at Tools → GPS Coordinates → Use my
>    location. Optional sign-in test account: qa@safecodeg.com / QATest@2024!
> 5. External services: Frankfurter (api.frankfurter.dev) for European Central
>    Bank exchange rates; Supabase for the optional sign-in; Apple StoreKit via
>    the in_app_purchase plugin for subscriptions and the lifetime purchase; the
>    Google Mobile Ads SDK is linked but ships with placeholder ad units in this
>    version, so no ads are served and no ATT prompt is presented. No AI
>    service, analytics SDK or push notifications are used.
> 6. The app functions consistently in all regions. The only variation is
>    user-selectable: 12 interface languages and 11 region presets that set the
>    default currency, number and date formatting, and the published 2025-26
>    income-tax brackets used by the tax calculator.
> 7. CalcMaster is not in a regulated industry and includes no protected
>    third-party material. It provides no financial, tax, medical or legal
>    advice and holds no funds; exchange rates are public ECB data and tax
>    brackets are published government figures.
>
> Please let us know if anything else would help. We reply within one business
> day at contact@safecodeg.com.

## 4. Still open

- **App Review contact is a placeholder** — "App Reviewer", +1 415 555 0142.
  Replace with a name and phone Apple can actually reach.
- **Ads vs. App Privacy.** `adsEnabled` is true but the ad units are still
  Google's test IDs, so `adsReady` is false and nothing serves. If the App
  Privacy declaration claims Device ID / advertising data collection, either
  ship real ad units or relax the declaration so the two agree.
