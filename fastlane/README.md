# Fastlane — CalcMaster

Automated store uploads for **CalcMaster** (`com.americangroupllc.calcmaster`).
All credentials come from environment variables / GitHub Secrets — nothing
secret is committed.

## Lanes

| Command | What it does |
|---|---|
| `fastlane ios test` | Run the Flutter test suite |
| `fastlane ios build` | Build a release `.ipa` via Flutter |
| `fastlane ios beta` | Build + upload to **TestFlight** (Internal Beta group) |
| `fastlane ios release` | Submit the latest TestFlight build to the App Store for review |
| `fastlane android beta` | Build the AAB + upload to the Play **internal** track |
| `fastlane android release` | Promote the internal build to **production** |

## Required environment variables

### iOS (App Store Connect API key — no 2FA needed)

| Var | Where to get it |
|---|---|
| `ASC_KEY_ID` | App Store Connect → Users and Access → Integrations → Keys |
| `ASC_ISSUER_ID` | Same page (shown above the key list) |
| `ASC_KEY_CONTENT` | The `.p8` file contents, **base64-encoded** (`base64 -i AuthKey_XXXX.p8`) |
| `APPLE_TEAM_ID` | Apple Developer → Membership |
| `FASTLANE_APPLE_ID` | (optional) your Apple account email |

> **Signing:** `flutter build ipa` needs a distribution certificate + App Store
> provisioning profile in the keychain. Set up [`fastlane match`](https://docs.fastlane.tools/actions/match/)
> (recommended) or import them in the CI job before the Fastlane step.

### Android (Play Developer API service account)

| Var | Where to get it |
|---|---|
| `PLAY_JSON_KEY_FILE` | Path to a service-account JSON with "Release manager" access (Play Console → Setup → API access) |

## Local usage

```bash
bundle install                       # installs fastlane from the Gemfile
export ASC_KEY_ID=... ASC_ISSUER_ID=... ASC_KEY_CONTENT=... APPLE_TEAM_ID=...
bundle exec fastlane ios beta

export PLAY_JSON_KEY_FILE=fastlane/play-service-account.json
bundle exec fastlane android beta
```

## CI (GitHub Actions)

`.github/workflows/deploy.yml` runs these lanes. Configure these **repository
secrets** (Settings → Secrets and variables → Actions):

- **iOS:** `ASC_KEY_CONTENT` (base64 .p8), `IOS_DIST_P12_BASE64` (base64 cert+key), `IOS_DIST_P12_PASSWORD`, `FASTLANE_APPLE_ID`
  - (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `APPLE_TEAM_ID` are baked into the repo; signing is manual — no `match` repo)
- **Android:** `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `PLAY_SERVICE_ACCOUNT_JSON`

Full step-by-step (accounts, one-time clicks, launch sequence): **`docs/GO_LIVE.md`**.

Trigger manually via **Actions → Deploy (Fastlane) → Run workflow** (pick platform + lane),
or push a `v*` tag to run `beta` on both platforms.
