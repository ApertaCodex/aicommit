#!/usr/bin/env bash
set -euo pipefail

CHANGELOG="CHANGELOG.md"
ERRORS=0

check() {
  if ! grep -q "$1" "$CHANGELOG"; then
    echo "❌ FAIL: $2"
    ((ERRORS++))
  else
    echo "✅ PASS: $2"
  fi
}

echo "Validating CHANGELOG.md..."
echo ""

if [ ! -f "$CHANGELOG" ]; then
  echo "❌ FAIL: CHANGELOG.md not found"
  exit 1
fi

check "^# Changelog" "Has '# Changelog' title"
check "keepachangelog.com" "Links to keepachangelog.com"
check "## \[Unreleased\]" "Has [Unreleased] section"

echo ""
if [ $ERRORS -gt 0 ]; then
  echo "❌ CHANGELOG validation failed with $ERRORS errors"
  exit 1
fi

echo "✅ CHANGELOG.md is valid"
exit 0
