#!/usr/bin/env bash
# 04-brew-packages.sh - Install packages from Brewfile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

BREWFILE="$PACKAGES_DIR/Brewfile"

# Ensure brew is in PATH
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "$HOME/.linuxbrew" ]]; then
    eval "$("$HOME/.linuxbrew/bin/brew shellenv")"
fi

if ! command_exists brew; then
    log_error "Homebrew not found. Run 03-homebrew.sh first."
    exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
    log_warning "No Brewfile found at $BREWFILE, skipping"
    exit 0
fi

log_info "Installing packages from Brewfile..."
log_info "This may take a while..."

# Use bundle to install everything
cd "$PACKAGES_DIR"
brew bundle install --file="$BREWFILE" --no-lock

log_success "Homebrew packages installed"

# Show any failures
if brew bundle check --file="$BREWFILE" &>/dev/null; then
    log_success "All Brewfile packages installed successfully"
else
    log_warning "Some packages may have failed. Run 'brew bundle check' for details."
fi
