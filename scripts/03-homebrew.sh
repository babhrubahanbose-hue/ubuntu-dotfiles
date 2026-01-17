#!/usr/bin/env bash
# 03-homebrew.sh - Install Homebrew (Linuxbrew)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

if command_exists brew; then
    log_info "Homebrew already installed, updating..."
    brew update
    log_success "Homebrew updated"
    exit 0
fi

log_info "Installing Homebrew..."

# Install dependencies
sudo apt-get install -y build-essential procps curl file git

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to path for current session
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "$HOME/.linuxbrew" ]]; then
    eval "$("$HOME/.linuxbrew/bin/brew shellenv")"
fi

# Add to shell profile if not already there
BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [[ -f "$profile" ]] && ! grep -q "linuxbrew" "$profile"; then
        echo "" >> "$profile"
        echo "# Homebrew" >> "$profile"
        echo "$BREW_SHELLENV" >> "$profile"
    fi
done

log_success "Homebrew installed"
log_info "Note: You may need to restart your terminal or run: eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
