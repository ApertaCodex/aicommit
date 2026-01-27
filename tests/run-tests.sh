#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "Running aicommit integration tests"
echo "=========================================="
echo ""

# Check if BATS is installed
if ! command -v bats &> /dev/null; then
  echo "❌ Error: BATS is not installed"
  echo ""
  echo "Install BATS with:"
  echo "  git clone https://github.com/bats-core/bats-core.git /tmp/bats-core"
  echo "  cd /tmp/bats-core && sudo ./install.sh /usr/local"
  exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Project directory: $PROJECT_DIR"
echo "Running tests from: $SCRIPT_DIR"
echo ""

# Run BATS tests
echo "Running integration tests..."
bats "$SCRIPT_DIR/integration/"*.bats

echo ""
echo "=========================================="
echo "✅ All tests passed!"
echo "=========================================="
