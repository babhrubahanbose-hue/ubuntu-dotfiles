#!/usr/bin/env bash
# 10-shell-setup.sh - Install zsh and Oh-My-Zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

# Install zsh
if ! command_exists zsh; then
    log_info "Installing zsh..."
    sudo apt-get install -y zsh
fi

# Install Oh-My-Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh-My-Zsh..."

    # Install without changing shell (we'll do that at the end)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    log_success "Oh-My-Zsh installed"
else
    log_info "Oh-My-Zsh already installed"
fi

# Set zsh as default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    log_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Default shell changed to zsh (will take effect on next login)"
fi

log_success "Shell setup complete"
