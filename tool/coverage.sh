#!/usr/bin/env bash
# Generate filtered LCOV coverage and enforce ≥90% line, ≥85% branch.
set -euo pipefail

COVERAGE_DIR="coverage"
LCOV_FILE="$COVERAGE_DIR/lcov.info"
FILTERED="$COVERAGE_DIR/lcov.filtered.info"
LINE_THRESHOLD=90
BRANCH_THRESHOLD=85

mkdir -p "$COVERAGE_DIR"

flutter test --coverage --branch-coverage

if [ ! -f "$LCOV_FILE" ]; then
  echo "❌ no lcov.info produced"
  exit 1
fi

# Strip generated + boilerplate
lcov \
  --remove "$LCOV_FILE" \
    '**/*.g.dart' \
    '**/*.freezed.dart' \
    '**/*.gr.dart' \
    '**/generated/**' \
    '**/main.dart' \
  --output-file "$FILTERED" \
  --ignore-errors unused

# Compute summary
SUMMARY=$(lcov --summary "$FILTERED" 2>&1)
echo "$SUMMARY"

LINE_PCT=$(echo "$SUMMARY" | grep -oE 'lines\.+: [0-9.]+%' | grep -oE '[0-9.]+' | head -1)
BRANCH_PCT=$(echo "$SUMMARY" | grep -oE 'branches\.+: [0-9.]+%' | grep -oE '[0-9.]+' | head -1)

LINE_PCT=${LINE_PCT:-0}
BRANCH_PCT=${BRANCH_PCT:-0}

LINE_OK=$(awk -v l="$LINE_PCT" -v t="$LINE_THRESHOLD" 'BEGIN{print (l+0 >= t)?1:0}')
BRANCH_OK=$(awk -v b="$BRANCH_PCT" -v t="$BRANCH_THRESHOLD" 'BEGIN{print (b+0 >= t)?1:0}')

genhtml "$FILTERED" -o "$COVERAGE_DIR/html" --quiet || true

if [ "$LINE_OK" != "1" ]; then
  echo "❌ line coverage $LINE_PCT% < $LINE_THRESHOLD%"
  exit 1
fi
if [ "$BRANCH_OK" != "1" ]; then
  echo "❌ branch coverage $BRANCH_PCT% < $BRANCH_THRESHOLD%"
  exit 1
fi

echo "✅ coverage: lines=$LINE_PCT% branches=$BRANCH_PCT%"
