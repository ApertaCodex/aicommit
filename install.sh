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

BLUE='\033[36m'
RESET='\033[0m'
indent="  "

echo ""
echo -e "${indent}${BLUE}████████╗ ██████╗          ██████╗   ██████╗  ███╗   ███╗ ███╗   ███╗ ██████╗ ████████╗${RESET}"
echo -e "${indent}${BLUE}██╔═══██║   ██╔═╝         ██╔═══██╗ ██╔═══██╗ ████╗ ████║ ████╗ ████║   ██╔═╝ ╚══██╔══╝${RESET}"
echo -e "${indent}${BLUE}██║█████║   ██║   ██████╗ ██║       ██║   ██║ ██╔████╔██║ ██╔████╔██║   ██║      ██║   ${RESET}"
echo -e "${indent}${BLUE}██║   ██║   ██║   ╚═════╝ ██║   ██║ ██║   ██║ ██║╚██╔╝██║ ██║╚██╔╝██║   ██║      ██║   ${RESET}"
echo -e "${indent}${BLUE}██║   ██║ ██████╗         ╚██████╔╝ ╚██████╔╝ ██║ ╚═╝ ██║ ██║ ╚═╝ ██║ ██████╗    ██║   ${RESET}"
echo -e "${indent}${BLUE}╚═╝   ╚═╝ ╚═════╝          ╚═════╝   ╚═════╝  ╚═╝     ╚═╝ ╚═╝     ╚═╝ ╚═════╝    ╚═╝   ${RESET}"
echo ""
echo -e "                                    ${GREEN}I N S T A L L E R${NC}"
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

# Check for existing installation
EXISTING_VERSION=""
if command -v aicommit &>/dev/null; then
    EXISTING_VERSION=$(aicommit --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || true)
    if [[ -n "$EXISTING_VERSION" ]]; then
        print_info "Existing installation found: v${EXISTING_VERSION}"
    else
        print_info "Existing installation found (unknown version)"
    fi
else
    print_info "No existing installation found"
fi

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

# Display installed version
INSTALLED_VERSION=$(grep -oP 'VERSION="\K[^"]+' "$INSTALL_DIR/aicommit" 2>/dev/null || true)
if [[ -n "$INSTALLED_VERSION" ]]; then
    if [[ -n "$EXISTING_VERSION" ]]; then
        if [[ "$EXISTING_VERSION" == "$INSTALLED_VERSION" ]]; then
            print_success "aicommit v${INSTALLED_VERSION} reinstalled (same version)"
        else
            print_success "aicommit upgraded: v${EXISTING_VERSION} → v${INSTALLED_VERSION}"
        fi
    else
        print_success "aicommit v${INSTALLED_VERSION} installed to $INSTALL_DIR/aicommit"
    fi
else
    print_success "aicommit installed to $INSTALL_DIR/aicommit"
fi

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
print_success "Installation complete!"
echo

# ---------- Provider detection & selection ----------
echo
print_info "Detecting available AI providers..."
echo

CONFIG_FILE="$HOME/.aicommitrc"
DETECTED_PROVIDERS=()
DETECTED_LABELS=()

if [[ -n "${OPENAI_API_KEY:-}" ]]; then
    DETECTED_PROVIDERS+=("openai")
    DETECTED_LABELS+=("OpenAI (OPENAI_API_KEY found)")
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    DETECTED_PROVIDERS+=("anthropic")
    DETECTED_LABELS+=("Anthropic / Claude (ANTHROPIC_API_KEY found)")
fi

if [[ -n "${GEMINI_API_KEY:-}" ]]; then
    DETECTED_PROVIDERS+=("gemini")
    DETECTED_LABELS+=("Google Gemini (GEMINI_API_KEY found)")
fi

if [[ -n "${GROQ_API_KEY:-}" ]]; then
    DETECTED_PROVIDERS+=("groq")
    DETECTED_LABELS+=("Groq (GROQ_API_KEY found)")
fi

if command -v ollama &>/dev/null && curl -sf http://localhost:11434/api/tags &>/dev/null; then
    DETECTED_PROVIDERS+=("ollama")
    DETECTED_LABELS+=("Ollama (local server running)")
elif command -v ollama &>/dev/null; then
    DETECTED_PROVIDERS+=("ollama")
    DETECTED_LABELS+=("Ollama (installed, server not running)")
fi

if [[ -n "${AICOMMIT_CUSTOM_API_URL:-}" && -n "${AICOMMIT_CUSTOM_API_KEY:-}" ]]; then
    DETECTED_PROVIDERS+=("custom")
    DETECTED_LABELS+=("Custom endpoint ($AICOMMIT_CUSTOM_API_URL)")
fi

if [[ ${#DETECTED_PROVIDERS[@]} -eq 0 ]]; then
    print_info "No AI providers detected."
    echo
    echo "To use aicommit, set at least one provider API key:"
    echo
    echo "  export OPENAI_API_KEY='your-key'        # OpenAI"
    echo "  export ANTHROPIC_API_KEY='your-key'      # Anthropic / Claude"
    echo "  export GEMINI_API_KEY='your-key'          # Google Gemini"
    echo "  export GROQ_API_KEY='your-key'            # Groq"
    echo "  ollama pull llama3.2                       # Ollama (local)"
    echo "  export AICOMMIT_CUSTOM_API_URL='url'      # Custom OpenAI-compatible endpoint"
    echo "  export AICOMMIT_CUSTOM_API_KEY='key'"
    echo
    echo "Add the export to your shell profile (~/.bashrc, ~/.zshrc) to make it permanent."
    echo
else
    echo "Detected AI providers:"
    for i in "${!DETECTED_PROVIDERS[@]}"; do
        echo "  $((i+1))) ${DETECTED_LABELS[$i]}"
    done
    echo

    if [[ ${#DETECTED_PROVIDERS[@]} -eq 1 ]]; then
        SELECTED_PROVIDER="${DETECTED_PROVIDERS[0]}"
        print_success "Auto-selected: $SELECTED_PROVIDER (only provider available)"
    else
        # Check if stdin is a terminal (not piped)
        if [[ -t 0 ]]; then
            read -p "Select default provider [1-${#DETECTED_PROVIDERS[@]}]: " selection
            if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#DETECTED_PROVIDERS[@]} )); then
                SELECTED_PROVIDER="${DETECTED_PROVIDERS[$((selection-1))]}"
            else
                SELECTED_PROVIDER="${DETECTED_PROVIDERS[0]}"
                echo "Invalid selection. Defaulting to: $SELECTED_PROVIDER"
            fi
        else
            SELECTED_PROVIDER="${DETECTED_PROVIDERS[0]}"
            print_info "Non-interactive mode. Defaulting to: $SELECTED_PROVIDER"
        fi
    fi

    # Write to config file
    if [[ -f "$CONFIG_FILE" ]]; then
        # Update existing config
        if grep -q '^AICOMMIT_PROVIDER=' "$CONFIG_FILE" 2>/dev/null; then
            sed -i "s/^AICOMMIT_PROVIDER=.*/AICOMMIT_PROVIDER=$SELECTED_PROVIDER/" "$CONFIG_FILE"
        else
            echo "AICOMMIT_PROVIDER=$SELECTED_PROVIDER" >> "$CONFIG_FILE"
        fi
    else
        echo "AICOMMIT_PROVIDER=$SELECTED_PROVIDER" > "$CONFIG_FILE"
    fi

    print_success "Default provider set to: $SELECTED_PROVIDER (saved to ~/.aicommitrc)"
    echo
fi

echo "Usage:"
echo "  aicommit                        # Commit and push with AI-generated message"
echo "  aicommit --provider anthropic   # -p Use a specific provider for this run"
echo "  aicommit --no-push              # -n Commit only, don't push"
echo "  aicommit --yes                  # -y Non-interactive mode"
echo "  aicommit --changelog            # -c Update CHANGELOG.md with this commit"
echo "  aicommit --release patch        # -r Create a release (patch|minor|major|X.Y.Z)"
echo "  aicommit --help                 # -h Show help"
echo
echo "You can also use:"
echo "  git aicommit"
echo

exit 0
