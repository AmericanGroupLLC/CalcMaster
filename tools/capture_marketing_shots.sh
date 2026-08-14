#!/bin/bash
# =====================================================================
#  CalcMaster · App Store / Play screenshot capture
# =====================================================================
#
#  Captures the 5 store screenshots on a 6.9" iPhone simulator
#  (1320 x 2868 — the only iPhone size the App Store still requires;
#  Apple down-scales it for every smaller device).
#
#      ./tools/capture_marketing_shots.sh
#
#  Output (overwritten in place, fastlane naming = upload order):
#      fastlane/screenshots/en-US/{1..5}_*.png
#      fastlane/metadata/android/en-US/images/phoneScreenshots/  (mirrored)
#
#  Each shot is taken by temporarily rewriting the router's
#  initialLocation so the app boots straight onto the target screen;
#  the original value is always restored, even on failure.
# =====================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER:-/Users/spatchava/agl/.flutter-sdk/bin/flutter}"
BUNDLE_ID="com.americangroupllc.calcmaster"
APP="$ROOT/build/ios/iphonesimulator/Runner.app"
IOS_SHOTS="$ROOT/fastlane/screenshots/en-US"
PLAY_SHOTS="$ROOT/fastlane/metadata/android/en-US/images/phoneScreenshots"
ROUTER="$ROOT/lib/app_router.dart"
SIM_NAME="${SIM_NAME:-iPhone 17 Pro Max}"   # 6.9" — 1320 x 2868

mkdir -p "$IOS_SHOTS" "$PLAY_SHOTS"

# Resolve the simulator by name so this isn't tied to one machine's UDIDs.
UDID=$(xcrun simctl list devices available \
  | grep -F "$SIM_NAME (" | head -1 \
  | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
[[ -n "$UDID" ]] || { echo "✗ No available simulator named '$SIM_NAME'" >&2; exit 1; }
echo "✓ Simulator: $SIM_NAME ($UDID)"

# Always put the router back the way we found it.
ORIGINAL_ROUTE=$(grep -oE "initialLocation: '[^']*'" "$ROUTER" | head -1 | sed -E "s/.*'(.*)'/\1/")
restore() {
  /usr/bin/sed -i '' -E "s|initialLocation: '/[^']*',|initialLocation: '${ORIGINAL_ROUTE}',|" "$ROUTER"
  xcrun simctl status_bar "$UDID" clear 2>/dev/null || true
}
trap restore EXIT
echo "✓ Router initialLocation will be restored to '$ORIGINAL_ROUTE'"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true
# Clean, deterministic status bar instead of whatever the host clock says.
xcrun simctl status_bar "$UDID" override \
  --time "9:41" --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 2>/dev/null || true

capture() {
  local route=$1 name=$2
  echo ""
  echo "=== /$route → $name ==="
  /usr/bin/sed -i '' -E "s|initialLocation: '/[^']*',|initialLocation: '/${route}',|" "$ROUTER"
  "$FLUTTER" build ios --simulator --debug 2>&1 | tail -2
  xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$UDID" "$APP"
  xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null
  sleep 7   # let the first frame settle (fonts, SVG icons, FX rates)
  xcrun simctl io "$UDID" screenshot "$IOS_SHOTS/$name.png" 2>&1 | grep -i wrote || true
  cp "$IOS_SHOTS/$name.png" "$PLAY_SHOTS/$name.png"
}

capture "convert"   "1_convert-home"
capture "calculate" "2_calculate-hub"
capture "finance"   "3_finance-hub"
capture "tools"     "4_tools-hub"
capture "paywall"   "5_paywall"

echo ""
echo "=== Inventory ==="
for f in "$IOS_SHOTS"/*.png; do
  printf '  %-40s %s\n' "$(basename "$f")" \
    "$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/{printf "%s ", $2}')"
done
