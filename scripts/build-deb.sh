#!/usr/bin/env bash
set -euo pipefail

VERSION="${1#v}"
ARCH="all"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 v1.2.3"
  exit 1
fi

echo "Building Debian package for version ${VERSION}..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Create package structure
PKG_DIR="/tmp/aicommit-deb-$$"
mkdir -p "$PKG_DIR/usr/local/bin"

# Copy files
cp "$PROJECT_DIR/aicommit" "$PKG_DIR/usr/local/bin/"
chmod +x "$PKG_DIR/usr/local/bin/aicommit"

# Create git-aicommit symlink content (wrapper script)
cat > "$PKG_DIR/usr/local/bin/git-aicommit" << 'EOF'
#!/usr/bin/env bash
exec aicommit "$@"
EOF
chmod +x "$PKG_DIR/usr/local/bin/git-aicommit"

# Build .deb with fpm
cd "$PROJECT_DIR"
fpm -s dir -t deb \
  -n aicommit \
  -v "$VERSION" \
  -a "$ARCH" \
  --description "AI-powered conventional commit message generator" \
  --url "https://github.com/ApertaCodex/aicommit" \
  --license "MIT" \
  --maintainer "Apertacodex <noreply@github.com>" \
  --depends jq \
  --depends curl \
  --depends git \
  -C "$PKG_DIR" \
  usr/local/bin/aicommit \
  usr/local/bin/git-aicommit

# Cleanup
rm -rf "$PKG_DIR"

echo "✅ Debian package created: aicommit_${VERSION}_${ARCH}.deb"
ls -lh aicommit_*.deb
