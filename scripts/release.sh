#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 v1.2.3"
  exit 1
fi

# Validate version format
if ! [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format. Use v1.2.3"
  exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR" || exit 1

# Validate CHANGELOG
echo "Validating CHANGELOG.md..."
if ! "$SCRIPT_DIR/validate-changelog.sh"; then
  echo "Error: CHANGELOG.md validation failed"
  exit 1
fi

# Check for unreleased content
if ! grep -A 10 "## \[Unreleased\]" CHANGELOG.md | grep -q "^###"; then
  echo "Error: No unreleased changes in CHANGELOG.md"
  echo "Please add changes before creating a release"
  exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "Error: You have uncommitted changes"
  echo "Please commit or stash them before creating a release"
  exit 1
fi

# Confirm with user
echo ""
echo "Ready to create release ${VERSION}"
echo "This will:"
echo "  1. Create git tag ${VERSION}"
echo "  2. Push tag to origin"
echo "  3. Trigger automated release workflow"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Release cancelled"
  exit 0
fi

# Create tag
git tag -a "$VERSION" -m "Release $VERSION"

# Push tag
git push origin "$VERSION"

echo ""
echo "✅ Tag ${VERSION} created and pushed"
echo "GitHub Actions will now:"
echo "  - Update CHANGELOG.md"
echo "  - Create GitHub release"
echo "  - Build packages (deb, rpm)"
echo "  - Publish release artifacts"
echo ""
echo "Monitor progress at:"
echo "https://github.com/ApertaCodex/aicommit/actions"
