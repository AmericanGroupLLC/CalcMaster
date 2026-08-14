#!/bin/bash
# =====================================================================
#  CalcMaster · iOS release via XCODE automatic signing (no ASC API key)
# =====================================================================
#
#  Use this instead of ios_appstore_submit.sh when you do NOT have a
#  working App Store Connect API key. Signing is done by Xcode's
#  automatic provisioning using the Apple ID signed into Xcode.
#
#  ONE-TIME SETUP (interactive, cannot be scripted):
#      Xcode → Settings → Accounts → + → Apple ID
#      Sign in with the account that belongs to team TLH7Z3G27A
#      (American Group LLC). Confirm the team is listed.
#
#  Usage:
#      ./tools/ios_appstore_submit_xcode.sh            # build + sign only
#      UPLOAD=1 ./tools/ios_appstore_submit_xcode.sh   # also upload + submit
#
#  Upload auth (only when UPLOAD=1) — app-specific password, NOT your
#  real Apple ID password. Create one at https://account.apple.com
#  → Sign-In and Security → App-Specific Passwords.
#      export FASTLANE_USER='you@example.com'
#      export FASTLANE_PASSWORD='abcd-efgh-ijkl-mnop'
#
#  Optional:
#      BUILD_NUMBER=2   CFBundleVersion (must be unique per version)
# =====================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER:-/Users/spatchava/agl/.flutter-sdk/bin/flutter}"
TEAM_ID="TLH7Z3G27A"
BUNDLE_ID="com.americangroupllc.calcmaster"
ARCHIVE="$ROOT/build/ios/archive/Runner.xcarchive"
IPA_DIR="$ROOT/build/ios/ipa"
EXPORT_PLIST="$ROOT/build/ios/ExportOptions.plist"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
section() { echo -e "\n${GREEN}===${NC} $1 ${GREEN}===${NC}\n"; }
fail()    { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }
warn()    { echo -e "${YELLOW}! $1${NC}"; }

# --- 1. Preflight ----------------------------------------------------
section "Preflight"
[[ -x "$FLUTTER" ]] || fail "Flutter SDK not executable at $FLUTTER"

if ! security find-identity -v -p codesigning | grep -q "Apple Distribution"; then
  fail "No 'Apple Distribution' identity in the keychain."
fi
echo "✓ Apple Distribution identity present"

# Xcode must have an Apple ID signed in, otherwise -allowProvisioningUpdates
# cannot create the App Store profile and the archive step fails.
if ! security find-generic-password -s "Xcode-Token" >/dev/null 2>&1 \
   && ! security find-internet-password -s idmsa.apple.com >/dev/null 2>&1; then
  warn "No Xcode Apple ID session found in the keychain."
  warn "If the archive fails to provision, open Xcode → Settings → Accounts and sign in."
fi

if [[ "${UPLOAD:-}" == "1" ]]; then
  [[ -n "${FASTLANE_USER:-}"     ]] || fail "UPLOAD=1 requires FASTLANE_USER (Apple ID email)"
  [[ -n "${FASTLANE_PASSWORD:-}" ]] || fail "UPLOAD=1 requires FASTLANE_PASSWORD (app-specific password)"
fi

# --- 2. Dependencies -------------------------------------------------
section "Dependencies"
"$FLUTTER" pub get
(cd ios && pod install)

# --- 3. Compile Dart + engine (Xcode does the signing, not Flutter) --
section "Flutter release build"
BUILD_ARGS=(--release --no-codesign)
[[ -n "${BUILD_NUMBER:-}" ]] && BUILD_ARGS+=(--build-number="$BUILD_NUMBER")
"$FLUTTER" build ios "${BUILD_ARGS[@]}"

# --- 4. Archive with automatic signing -------------------------------
# CODE_SIGN_IDENTITY is forced to "Apple Distribution" because the project
# still carries a legacy `CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`
# at the project level, which can otherwise resolve to a development cert.
section "Archive (Xcode automatic signing)"
rm -rf "$ARCHIVE"
xcodebuild archive \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic \
  "CODE_SIGN_IDENTITY[sdk=iphoneos*]=Apple Distribution"

# --- 5. Export a signed App Store .ipa -------------------------------
section "Export signed .ipa"
mkdir -p "$IPA_DIR"
cat > "$EXPORT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>${TEAM_ID}</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>destination</key><string>export</string>
</dict>
</plist>
PLIST

rm -f "$IPA_DIR"/*.ipa
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -exportPath "$IPA_DIR" \
  -allowProvisioningUpdates

IPA=$(ls -t "$IPA_DIR"/*.ipa 2>/dev/null | head -1)
[[ -n "$IPA" ]] || fail "Export produced no .ipa"
section "Signed IPA"
echo "  $IPA"
codesign -dv --verbose=2 "$IPA" 2>&1 | grep -Ei 'Authority|TeamIdentifier' | sed 's/^/  /' || true

# --- 6. Upload + submit for review -----------------------------------
if [[ "${UPLOAD:-}" != "1" ]]; then
  section "Next step"
  echo "Build is signed but NOT uploaded. To upload:"
  echo "  • Xcode → Window → Organizer → Distribute App, or"
  echo "  • re-run with UPLOAD=1 plus FASTLANE_USER / FASTLANE_PASSWORD"
  exit 0
fi

section "Upload + submit for App Review"
warn "This submits CalcMaster to App Review and auto-releases on approval."
IPA_PATH="$IPA" bundle exec fastlane ios release_xcode
