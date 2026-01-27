#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
TARBALL_URL="https://github.com/ApertaCodex/aicommit/archive/${VERSION}.tar.gz"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 v1.2.3"
  exit 1
fi

echo "Updating Homebrew formula for ${VERSION}..."

# Download tarball and calculate SHA256
echo "Calculating SHA256 for tarball..."
SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | cut -d' ' -f1)
echo "Tarball SHA256: ${SHA256}"

# Clone homebrew tap (or use existing clone)
TAP_DIR="/tmp/homebrew-aicommit-$$"
git clone https://github.com/ApertaCodex/homebrew-aicommit.git "$TAP_DIR"
cd "$TAP_DIR"

# Update formula
echo "Updating Formula/aicommit.rb..."
sed -i.bak "s|url \".*\"|url \"${TARBALL_URL}\"|" Formula/aicommit.rb
sed -i.bak "s|sha256 \".*\"|sha256 \"${SHA256}\"|" Formula/aicommit.rb
rm Formula/aicommit.rb.bak

# Show diff
echo "Changes:"
git diff Formula/aicommit.rb

# Commit and push
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add Formula/aicommit.rb
git commit -m "aicommit ${VERSION}"
git push

# Cleanup
cd -
rm -rf "$TAP_DIR"

echo "✅ Homebrew formula updated to ${VERSION}"
