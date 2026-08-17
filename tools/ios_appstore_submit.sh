#!/bin/bash
# =====================================================================
#  CalcMaster · iOS build → sign → upload → submit for App Review
# =====================================================================
#
#  Usage:
#      ./tools/ios_appstore_submit.sh /path/to/AuthKey_UV8NYF9767.p8
#
#  Or, if ASC_KEY_CONTENT is already exported (base64 of the .p8):
#      ./tools/ios_appstore_submit.sh
#
#  Optional env:
#      BUILD_NUMBER=2          bump CFBundleVersion (must be unique per version)
#      BOOTSTRAP=1             also create the App Store Connect app record
#      SKIP_SCREENSHOTS=1      don't re-capture; upload fastlane/screenshots as-is
#
#  What it does:
#      1. flutter pub get + pod install
#      2. fastlane ios release
#           → fetches/creates the App Store provisioning profile via the API key
#           → flutter build ipa --release --export-method app-store  (signed)
#           → uploads binary + fastlane/metadata + fastlane/screenshots
#           → submits for App Review with automatic release on approval
# =====================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER:-/Users/spatchava/agl/.flutter-sdk/bin/flutter}"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
section() { echo -e "\n${GREEN}===${NC} $1 ${GREEN}===${NC}\n"; }
fail()    { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }
warn()    { echo -e "${YELLOW}! $1${NC}"; }

# --- 1. App Store Connect API key ------------------------------------
# ASC_KEY_ID / ASC_ISSUER_ID are identifiers, not secrets, and are already
# defaulted in fastlane/Fastfile. Only the .p8 private key is needed here.
if [[ -n "${1:-}" ]]; then
  [[ -f "$1" ]] || fail "No such .p8 file: $1"
  ASC_KEY_CONTENT="$(base64 -i "$1" | tr -d '\n')"
  export ASC_KEY_CONTENT
fi
[[ -n "${ASC_KEY_CONTENT:-}" ]] || fail \
  "ASC_KEY_CONTENT is unset. Pass the .p8 path as \$1, or export the base64 of it.
   The verified team key is UV8NYF9767 (issuer ec93cc91-97c2-4b03-860b-697d7ec5d1fb).
   A .p8 downloads only once — if it is lost, generate a NEW team key at
   App Store Connect → Users and Access → Integrations → App Store Connect API
   (no need to revoke the old one) and set ASC_KEY_ID to the new key ID."

# --- 2. Preflight ----------------------------------------------------
section "Preflight"
[[ -x "$FLUTTER" ]] || fail "Flutter SDK not executable at $FLUTTER"
command -v bundle >/dev/null || fail "bundler not installed — run: gem install bundler"

# A distribution cert must already be in the login keychain. The provisioning
# profile is fetched by fastlane, but the cert + private key cannot be.
if ! security find-identity -v -p codesigning | grep -q "Apple Distribution"; then
  fail "No 'Apple Distribution' identity in the keychain. Import the .p12 that
   pairs the cert with its private key (Keychain Access → export 2 items)."
fi
echo "✓ Apple Distribution identity present"
echo "✓ Version: $(grep -E '^version:' pubspec.yaml)"

# App Store Connect rejects some non-ASCII characters in listing text, and it
# only tells you AFTER the archive + IPA export have run (~2 min wasted). A
# stray "xʸ" (U+02B8 MODIFIER LETTER SMALL Y) in the description cost exactly
# that. Catch the whole class up front: modifier letters (Lm), modifier symbols
# (Sk) and "other numbers" (No, e.g. superscript ²) are the ones that bite.
# Em dash, bullet, middle dot, √ and arrows are all fine and stay allowed.
python3 - <<'PY' || fail "Fix the characters above before building."
import glob, sys, unicodedata
bad = []
for f in sorted(glob.glob('fastlane/metadata/**/*.txt', recursive=True)):
    for ch in sorted(set(open(f, encoding='utf-8').read())):
        if ord(ch) > 127 and unicodedata.category(ch) in ('Lm', 'Sk', 'No'):
            bad.append(f"  {f}: U+{ord(ch):04X} {ch!r} "
                       f"({unicodedata.name(ch, 'unnamed')})")
if bad:
    print("✗ Characters App Store Connect will reject:")
    print("\n".join(bad))
    sys.exit(1)
print("✓ Store metadata has no characters App Store Connect rejects")
PY

# Apple validates the App Review contact phone and rejects placeholders, again
# only AFTER the build. "+1 000 000 0000" failed with "The phone number must be
# in a valid format." Require E.164-ish digits and reject all-zero bodies.
python3 - <<'PY' || fail "Set a real App Review contact phone before building."
import re, sys
p = 'fastlane/metadata/review_information/phone_number.txt'
raw = open(p, encoding='utf-8').read().strip()
digits = re.sub(r'\D', '', raw)
body = digits[1:] if raw.startswith('+1') else digits
problem = None
if not raw.startswith('+'):
    problem = "must start with '+' followed by the country code"
elif len(digits) < 8:
    problem = f"only {len(digits)} digits — too short to be a real number"
elif set(body) <= {'0'}:
    problem = "is a placeholder (all zeros)"
if problem:
    print(f"✗ App Review phone {raw!r} {problem}.")
    print(f"  Apple rejects this during metadata upload. Edit {p}")
    print("  Example of an accepted format: +1 415 555 0142")
    sys.exit(1)
print(f"✓ App Review contact phone looks valid ({raw})")
PY

section "Dependencies"
"$FLUTTER" pub get
(cd ios && pod install)

# --- 3. Screenshots --------------------------------------------------
if [[ "${SKIP_SCREENSHOTS:-}" != "1" ]]; then
  section "Screenshots"
  ./tools/capture_marketing_shots.sh
else
  warn "SKIP_SCREENSHOTS=1 — uploading fastlane/screenshots/en-US as-is"
fi
ls -1 fastlane/screenshots/en-US/*.png | sed 's/^/  /'

# --- 4. One-time App Store Connect app record ------------------------
if [[ "${BOOTSTRAP:-}" == "1" ]]; then
  section "Bootstrap (register App ID + create ASC app record)"
  bundle exec fastlane ios bootstrap
fi

# --- 5. Build, sign, upload, submit ----------------------------------
section "Build → sign → upload → submit for review"
warn "This submits CalcMaster to App Review and auto-releases on approval."
bundle exec fastlane ios release

section "Uploaded — one step left"
cat <<'NEXT'
The binary, metadata and screenshots are uploaded, but NOT yet submitted.

Apple reviews the three in-app purchases alongside the binary on a first
release, and deliver cannot attach them. Once the build finishes processing
(5-15 min, you get an email), submit everything together:

    bundle exec ruby tools/ios_submit_for_review.rb            # dry run
    bundle exec ruby tools/ios_submit_for_review.rb --submit   # submit

Track status: https://appstoreconnect.apple.com
NEXT
