#!/bin/bash
# =====================================================================
#  CalcMaster · Upload v4.0.0 binaries to GitHub Release
# =====================================================================
#
#  Prerequisite: authenticate gh CLI once
#      gh auth login           # pick GitHub.com, SSH, follow browser flow
#
#  Then run:
#      ./tools/upload_release.sh
# =====================================================================

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

VERSION="v4.0.0"
DIST="dist/${VERSION}"

if ! gh auth status > /dev/null 2>&1; then
  echo "❌ gh CLI not authenticated. Run: gh auth login"
  exit 1
fi

if [ ! -d "$DIST" ]; then
  echo "❌ Artifacts not found at $DIST. Run ./tools/release_all.sh first."
  exit 1
fi

# Create the release if it doesn't exist; otherwise upload assets to existing one.
if gh release view "$VERSION" > /dev/null 2>&1; then
  echo "✓ Release $VERSION already exists. Uploading any missing assets…"
  gh release upload "$VERSION" \
    "$DIST"/*.apk \
    "$DIST"/*.aab \
    "$DIST"/*.tar.gz \
    "$DIST"/SHA256SUMS.txt \
    --clobber
else
  echo "✓ Creating new release $VERSION on the 'release' branch…"
  gh release create "$VERSION" \
    --target release \
    --title "CalcMaster $VERSION" \
    --notes-file RELEASES.md \
    "$DIST/CalcMaster-${VERSION}-android.apk" \
    "$DIST/CalcMaster-${VERSION}-android.aab" \
    "$DIST/CalcMaster-${VERSION}-ios-unsigned.tar.gz" \
    "$DIST/CalcMaster-${VERSION}-web.tar.gz" \
    "$DIST/SHA256SUMS.txt"
fi

echo ""
echo "=== Release URL ==="
gh release view "$VERSION" --json url --jq '.url'
