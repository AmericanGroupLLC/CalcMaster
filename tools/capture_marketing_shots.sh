#!/bin/bash
set -e
ROOT=/Users/spatchava/Master-Cal
SHOTS=$ROOT/marketing/screenshots
APP=$ROOT/build/ios/iphonesimulator/Runner.app
PRO_MAX=3A41E921-1471-466E-BCDA-30E428297CCF
P17=1555CF80-6CB0-44AE-98BB-C38FD7B0E866

capture() {
  local route=$1
  local label=$2
  echo "=== Route /$route → $label ==="
  # Patch initialLocation
  /usr/bin/sed -i '' -E "s|initialLocation: '/[^']*',|initialLocation: '/${route}',|" $ROOT/lib/app_router.dart
  cd $ROOT
  flutter build ios --simulator --debug 2>&1 | tail -2
  for udid in $PRO_MAX $P17; do
    case $udid in
      $PRO_MAX) tag="6.9" ;;
      $P17) tag="6.1" ;;
    esac
    xcrun simctl uninstall $udid com.calcmaster.calcmaster 2>/dev/null || true
    xcrun simctl install $udid "$APP" 2>&1 | tail -1
    xcrun simctl launch $udid com.calcmaster.calcmaster 2>&1 | tail -1
    sleep 7
    xcrun simctl io $udid screenshot $SHOTS/iphone-${tag}-${label}.png 2>&1 | grep -i wrote || true
  done
}

capture "calculate" "calculate-hub"
capture "finance" "finance-hub"
capture "tools" "tools-hub"
capture "settings" "settings"
capture "paywall" "paywall"

# Restore default
/usr/bin/sed -i '' -E "s|initialLocation: '/[^']*',|initialLocation: '/convert',|" $ROOT/lib/app_router.dart
echo ""
echo "=== Final inventory ==="
ls -la $SHOTS/
