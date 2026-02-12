#!/usr/bin/env bash

# install.sh
# Installation script for aicommit

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
    SUDO=""
else
    INSTALL_DIR="/usr/local/bin"
    SUDO="sudo"
fi

# Determine if running from pipe (curl | bash) or locally
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    # Running locally from a file
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REMOTE_INSTALL=false
else
    # Running from pipe (curl | bash)
    SCRIPT_DIR="/tmp/aicommit-install-$$"
    REMOTE_INSTALL=true
    mkdir -p "$SCRIPT_DIR"
fi

echo "========================================"
echo "  AI Commit Installation"
echo "========================================"
echo

# Check prerequisites
print_info "Checking prerequisites..."

# Check for git
if ! command -v git &>/dev/null; then
    print_error "git is not installed. Please install git first."
    exit 1
fi
print_success "git found"

# Check for jq
if ! command -v jq &>/dev/null; then
    print_error "jq is not installed"
    echo
    echo "Please install jq:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS: brew install jq"
    echo "  Arch Linux: sudo pacman -S jq"
    exit 1
fi
print_success "jq found"

# Check for curl
if ! command -v curl &>/dev/null; then
    print_error "curl is not installed. Please install curl first."
    exit 1
fi
print_success "curl found"

echo

# Download or copy aicommit script
if [[ "$REMOTE_INSTALL" == true ]]; then
    print_info "Downloading aicommit from GitHub..."

    # Download the latest aicommit script
    DOWNLOAD_URL="https://raw.githubusercontent.com/apertacodex/aicommit/main/aicommit"

    if ! curl -fsSL "$DOWNLOAD_URL" -o "$SCRIPT_DIR/aicommit"; then
        print_error "Failed to download aicommit from GitHub"
        rm -rf "$SCRIPT_DIR"
        exit 1
    fi

    print_success "Downloaded aicommit"
else
    # Check if aicommit script exists locally
    if [[ ! -f "$SCRIPT_DIR/aicommit" ]]; then
        print_error "aicommit script not found in $SCRIPT_DIR"
        exit 1
    fi
fi

# Install the script
print_info "Installing aicommit to $INSTALL_DIR..."

if [[ -w "$INSTALL_DIR" ]]; then
    cp "$SCRIPT_DIR/aicommit" "$INSTALL_DIR/aicommit"
    chmod +x "$INSTALL_DIR/aicommit"
else
    $SUDO cp "$SCRIPT_DIR/aicommit" "$INSTALL_DIR/aicommit"
    $SUDO chmod +x "$INSTALL_DIR/aicommit"
fi

print_success "aicommit installed to $INSTALL_DIR/aicommit"

# Cleanup temp directory for remote installs
if [[ "$REMOTE_INSTALL" == true ]]; then
    rm -rf "$SCRIPT_DIR"
fi

# Create git-aicommit wrapper if it doesn't exist
if [[ ! -f "$INSTALL_DIR/git-aicommit" ]]; then
    print_info "Creating git-aicommit wrapper..."

    if [[ -w "$INSTALL_DIR" ]]; then
        cat > "$INSTALL_DIR/git-aicommit" << 'EOF'
#!/usr/bin/env bash
aicommit "$@"
EOF
        chmod +x "$INSTALL_DIR/git-aicommit"
    else
        $SUDO bash -c "cat > $INSTALL_DIR/git-aicommit" << 'EOF'
#!/usr/bin/env bash
aicommit "$@"
EOF
        $SUDO chmod +x "$INSTALL_DIR/git-aicommit"
    fi

    print_success "git-aicommit wrapper created"
else
    print_info "git-aicommit already exists, skipping..."
fi

echo
echo "========================================"
print_success "Installation complete!"
echo "========================================"
echo

# Check for OPENAI_API_KEY
if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    print_info "OPENAI_API_KEY environment variable is not set"
    echo
    echo "To use aicommit, you need to set your OpenAI API key:"
    echo
    echo "  export OPENAI_API_KEY='your-api-key-here'"
    echo
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.) to make it permanent:"
    echo
    echo "  echo 'export OPENAI_API_KEY=\"your-api-key-here\"' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo
else
    print_success "OPENAI_API_KEY is already set"
fi

echo "Usage:"
echo "  aicommit              # Commit and push with AI-generated message"
echo "  aicommit --no-push    # -n Commit only, don't push"
echo "  aicommit --yes        # -y Non-interactive mode"
echo "  aicommit --changelog  # -c Update CHANGELOG.md with this commit"
echo "  aicommit --help       # -h Show help"
echo
echo "You can also use:"
echo "  git aicommit"
echo

exit 0
