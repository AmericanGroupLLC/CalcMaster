# CalcMaster · Go-Live Runbook

Everything that can be automated **is** automated. This doc lists the **one-time
human setup** and the **exact values I need from your Apple + Google accounts**.
Once these are in place, `git tag v4.0.1 && git push --tags` builds and uploads to
both stores automatically (TestFlight + Play internal track).

App identity (already set, don't change): `CalcMaster` · `com.americangroupllc.calcmaster` · `4.0.0 (1)`

---

## ✅ Done in the repo (no action needed)
- iOS export-compliance key (`ITSAppUsesNonExemptEncryption=false`) — no "Missing Compliance" stall
- Fastlane lanes: `ios beta/release/bootstrap`, `android beta/release/promote`
- iOS code signing via **fastlane match**, wired into CI
- Store **listing text + screenshots** auto-uploaded (`fastlane/metadata`, `fastlane/screenshots`)
- GitHub Actions: `deploy.yml` (build+upload) and `pages.yml` (live legal URLs)
- Android signing config (reads `key.properties`), `.gitignore` protects all secrets

---

## 🔑 PART A — What I need from your **Apple** account

Create these once, then add them as **GitHub repo secrets** (Settings → Secrets and variables → Actions):

> **Already set, no action (baked into the repo):**
> - Apple Developer Program enrollment **done** (American Group LLC, Organization)
> - **Team ID** `TLH7Z3G27A`
> - **ASC Key ID** `4YUXDMJC64` · **Issuer ID** `ec93cc91-97c2-4b03-860b-697d7ec5d1fb`
> - **Apple Distribution cert** created (valid to 2027-06-09) — signing is now **manual** (no `match` repo needed)
> So you do NOT need `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, or any `MATCH_*` secrets.

| Secret name | What it is / where to get it |
|---|---|
| `ASC_KEY_CONTENT` | Your `AuthKey_4YUXDMJC64.p8`, **base64-encoded**: `base64 -i AuthKey_4YUXDMJC64.p8 \| pbcopy`. ⚠️ Downloadable only ONCE — if you didn't save it, revoke `4YUXDMJC64` and make a new key. |
| `IOS_DIST_P12_BASE64` | The distribution **cert + private key** exported as a `.p12`, base64-encoded. The `.cer` is public-only; export the pair from **Keychain Access** (see below). |
| `IOS_DIST_P12_PASSWORD` | The password you set when exporting the `.p12` |
| `FASTLANE_APPLE_ID` | Your Apple account email |

**Export the `.p12` (turns your `.cer` into something that can sign):**
1. Open **Keychain Access** on the Mac where you created the certificate request.
2. Find **"Apple Distribution: American Group LLC (TLH7Z3G27A)"**, expand it — there must be a **private key** under it.
3. Select **both** the certificate and its private key → right-click → **Export 2 items… → .p12**, set a password.
4. `base64 -i dist.p12 | pbcopy` → secret `IOS_DIST_P12_BASE64`; the password → `IOS_DIST_P12_PASSWORD`.
> The **provisioning profile is fetched automatically** by the build lane via the API key — no manual profile step.

**One-time clicks only you can do (cannot be automated):**
1. ~~Enroll in the **Apple Developer Program**~~ ✅ done.  ~~Create distribution cert~~ ✅ done.
2. Run once locally to create the App Store Connect app record:
   ```bash
   bundle exec fastlane ios bootstrap     # registers App ID + creates the App Store Connect app
   ```
3. In App Store Connect: set **pricing = Free**, **Primary category = Utilities**, complete **App Privacy** (Location on-demand/not shared, AdMob ads + analytics), and create the 3 **subscription products** (Monthly $2.99 / Annual $19.99 / Lifetime $49.99).

---

## 🔑 PART B — What I need from your **Google Play** account

> **Already set, no action:**
> - Play Console account — **Account ID `5590631437738173959`**
> - Service account created — `american-group-publisher@american-group-llc.iam.gserviceaccount.com`
>   (project "American Group LLC", OAuth client `108071145710089945242`, key id `a5db41…b3a6a`)

> **Upload keystore generated:** `android/upload-keystore.jks` (alias `upload`), local
> `android/key.properties` wired. ⚠️ **Back up the `.jks` + its password (in `key.properties`) now** —
> store both in a password manager + a second location.

Add as GitHub repo secrets:

| Secret name | What it is / where to get it |
|---|---|
| `PLAY_SERVICE_ACCOUNT_JSON` | **The full JSON key file** for the service account above (it contains the secret `private_key`). Google Cloud → IAM → Service Accounts → that account → **Keys → Add key → JSON** → download → paste the **entire file** as the secret. The key id `a5db41…` is one such key; if you saved its JSON, use that. |
| `ANDROID_KEYSTORE_BASE64` | Your real upload keystore, base64: `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias (e.g. `upload`) |

**One-time clicks only you can do:**
1. ~~Create a **Google Play Console** account~~ ✅ done (Account ID `5590631437738173959`).
1b. **Grant the service account access in Play Console** (creating it in Google Cloud is not enough):
    Play Console → **Users and permissions → Invite new user** → email
    `american-group-publisher@american-group-llc.iam.gserviceaccount.com` →
    grant **Admin (all permissions)** or at least *Release* + *Edit store listing* for this app.
    (Also enable the **Google Play Android Developer API** in the GCP project once.)
2. Create the app and **upload the first AAB manually** — Google requires the first
   bundle through the dashboard; the API/Fastlane handles every build after that.
   Build it with: `flutter build appbundle --release` (needs `android/key.properties`).
3. Complete the **Data Safety** form + **Content rating** questionnaire (answers drafted in `marketing/listing-copy.md` §3).
4. Create the matching **subscription products**.

---

## 🌐 PART C — Publish the legal pages (URLs already wired)
Domain + support email are set everywhere: **`www.safecodeg.com`** / **`support@safecodeg.com`**.
The app + store metadata now point at:
- Privacy: `https://www.safecodeg.com/calcmaster/privacy.html`
- Terms:   `https://www.safecodeg.com/calcmaster/terms.html`
- Support: `https://www.safecodeg.com/calcmaster/support.html`

**You just need those pages to be LIVE at those exact paths.** Upload the contents of
`marketing/site/` to a `/calcmaster/` folder on `www.safecodeg.com` (the pages already
cross-link by relative filename, so they work as a folder).

> If you'd rather host them somewhere with a different path (root, or GitHub Pages),
> tell me the final paths and I'll re-point the metadata + config. The `.github/workflows/pages.yml`
> workflow is still available as a free fallback.
> Also confirm `support@safecodeg.com` is a real mailbox — Apple's reviewer emails it.

---

## 💰 PART D — Replace test monetization IDs (before earning / public launch)
`lib/monetization/monetization_config.dart` and `ios/Runner/Info.plist` currently use
Google's **test** AdMob IDs (`ca-app-pub-3940256099942544…`). Shipping with these = no
revenue + possible policy rejection. Give me (or paste in) your real **AdMob App IDs +
ad-unit IDs** and the **IAP product IDs** once created, and I'll wire them in.

---

## 🚀 The launch sequence (once A–D are done)
```bash
# 0. one-time: bootstrap + match (Part A.2), first manual Play upload (Part B.2)
# 1. verify locally
flutter pub get && flutter analyze && flutter build appbundle --release

# 2. ship a build to TestFlight + Play internal automatically
git tag v4.0.1 && git push --tags

# 3. when happy, promote to the public stores
bundle exec fastlane ios release       # submits to App Store review
bundle exec fastlane android release   # ships to Play production
```

## What stays manual (by store rule, not by us)
- Apple's **first app review** (~24h) is a human approval.
- Google Play's **first AAB** must be uploaded by hand (Part B.2).
- App Privacy / Data Safety forms are entered in the dashboards (answers are drafted).
