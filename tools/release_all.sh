#!/bin/bash
# =====================================================================
#  CalcMaster · Universal release builder
# =====================================================================
#
#  Builds all 4 deliverables and stages them in dist/ for upload.
#
#    ./tools/release_all.sh           # build all
#    ./tools/release_all.sh --android # only Android
#    ./tools/release_all.sh --ios     # only iOS
#    ./tools/release_all.sh --web     # only web build
#    ./tools/release_all.sh --site    # only marketing site
#    ./tools/release_all.sh --check   # only run analyze + tests
#
#  iOS .ipa requires a configured Apple Developer team. Without one
#  the script produces an unsigned Runner.app and prints next steps.
# =====================================================================

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/dist"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
section() { echo -e "\n${GREEN}===${NC} $1 ${GREEN}===${NC}\n"; }
warn() { echo -e "${YELLOW}!! $1${NC}"; }

ALL=true; ONLY_CHECK=false
for arg in "$@"; do
  case $arg in
    --android|--ios|--web|--site) ALL=false;;
    --check) ALL=false; ONLY_CHECK=true;;
  esac
done
do_run() {
  local flag=$1
  if $ALL; then return 0; fi
  for arg in "$@"; do
    if [[ "${flag}" == "${arg}" ]]; then return 0; fi
  done
  for arg in "$@"; do
    for cli_arg in "$@"; do : ; done
  done
  for arg in "$ALL_ARGS"; do : ; done
  return 1
}

cd "$ROOT"
mkdir -p "$DIST/android" "$DIST/ios" "$DIST/web" "$DIST/site"

section "1. Sanity: pub get + analyze + test"
flutter pub get | tail -3
flutter analyze 2>&1 | tail -3
flutter test 2>&1 | tail -3

if $ONLY_CHECK; then
  echo "✓ Check-only run complete."
  exit 0
fi

# ────────────────── Android ──────────────────
if $ALL || [[ "$*" == *"--android"* ]]; then
  section "2. Android — release APK + AAB"
  flutter build apk --release | tail -3
  flutter build appbundle --release | tail -3
  cp build/app/outputs/flutter-apk/app-release.apk "$DIST/android/CalcMaster-release.apk"
  cp build/app/outputs/bundle/release/app-release.aab "$DIST/android/CalcMaster-release.aab"
fi

# ────────────────── iOS ──────────────────
if $ALL || [[ "$*" == *"--ios"* ]]; then
  section "3. iOS — release Runner.app (codesign requires Apple Dev cert)"
  if flutter build ipa --release 2>&1 | tee /tmp/ipa-build.log | tail -3; then
    if [ -f build/ios/ipa/calcmaster.ipa ]; then
      cp build/ios/ipa/calcmaster.ipa "$DIST/ios/CalcMaster-release.ipa"
      echo "✓ Signed .ipa produced."
    else
      warn "ipa step ran but no .ipa file. Falling back to unsigned --no-codesign build."
      flutter build ios --release --no-codesign | tail -3
      cp -R build/ios/iphoneos/Runner.app "$DIST/ios/Runner.app"
    fi
  else
    warn "Codesign failed. Producing unsigned Runner.app instead."
    flutter build ios --release --no-codesign | tail -3
    cp -R build/ios/iphoneos/Runner.app "$DIST/ios/Runner.app"
    echo "Next step: open ios/Runner.xcworkspace in Xcode, configure Signing & Capabilities, then re-run with --ios."
  fi
fi

# ────────────────── Web ──────────────────
if $ALL || [[ "$*" == *"--web"* ]]; then
  section "4. Flutter Web — release"
  flutter build web --release | tail -3
  cp -R build/web/. "$DIST/web/"
fi

# ────────────────── Marketing site ──────────────────
if $ALL || [[ "$*" == *"--site"* ]]; then
  section "5. Marketing site (4 static pages)"
  cp -R marketing/site/. "$DIST/site/"
fi

# ────────────────── Summary ──────────────────
section "Summary"
ls -lhR "$DIST" | head -40
echo ""
echo "Next steps:"
echo "  • Android: drop dist/android/CalcMaster-release.aab into Play Console"
echo "  • iOS:     upload dist/ios/CalcMaster-release.ipa via Transporter"
echo "  • Web:     deploy dist/web/ to Firebase Hosting (target: webapp)"
echo "  • Site:    deploy dist/site/ to Firebase Hosting (target: marketing)"
echo ""
echo "Or:"
echo "  firebase deploy --only hosting:marketing,hosting:webapp"
