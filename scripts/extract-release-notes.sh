#!/usr/bin/env bash
set -euo pipefail

VERSION="${1#v}"  # Remove 'v' prefix

if [ -z "$VERSION" ]; then
  echo "Usage: $0 v1.2.3"
  exit 1
fi

# Extract content between ## [VERSION] and next ##
sed -n "/## \[${VERSION}\]/,/## \[/p" CHANGELOG.md | \
  sed '1d;$d' | \
  sed '/^$/d'
