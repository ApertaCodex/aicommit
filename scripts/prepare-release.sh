#!/usr/bin/env bash
set -euo pipefail

VERSION="${1#v}"  # Remove 'v' prefix if present
DATE=$(date +%Y-%m-%d)

if [ -z "$VERSION" ]; then
  echo "Usage: $0 v1.2.3"
  exit 1
fi

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format. Use v1.2.3"
  exit 1
fi

# Check if [Unreleased] has content
if ! grep -A 10 "## \[Unreleased\]" CHANGELOG.md | grep -q "^###"; then
  echo "Error: No unreleased changes in CHANGELOG.md"
  echo "Please add changes under [Unreleased] section first"
  exit 1
fi

echo "Preparing release v${VERSION}..."

# Create backup
cp CHANGELOG.md CHANGELOG.md.bak

# Extract unreleased content
UNRELEASED_CONTENT=$(awk '
  /## \[Unreleased\]/ { in_unreleased=1; next }
  /## \[/ { in_unreleased=0 }
  in_unreleased && /^###/ { print; getline; while(/^-/) { print; if(getline <= 0) break } }
' CHANGELOG.md)

if [ -z "$UNRELEASED_CONTENT" ]; then
  echo "Error: No content found in [Unreleased] section"
  rm CHANGELOG.md.bak
  exit 1
fi

# Create new CHANGELOG with version section
awk -v version="$VERSION" -v date="$DATE" -v content="$UNRELEASED_CONTENT" '
  /## \[Unreleased\]/ {
    print
    print ""
    print "## [" version "] - " date
    print content
    next
  }
  { print }
' CHANGELOG.md.bak > CHANGELOG.md

# Clean up backup
rm CHANGELOG.md.bak

echo "✅ CHANGELOG.md updated for v${VERSION}"
echo ""
echo "Changes moved to [${VERSION}] section:"
echo "$UNRELEASED_CONTENT"
echo ""
echo "Please review the changes and commit if satisfied"
