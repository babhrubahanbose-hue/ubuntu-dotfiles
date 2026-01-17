#!/usr/bin/env bash
# 11-shell-plugins.sh - Install Powerlevel10k and zsh plugins

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Ensure Oh-My-Zsh is installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_error "Oh-My-Zsh not found. Run 10-shell-setup.sh first."
    exit 1
fi

# Install Powerlevel10k
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    log_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    log_success "Powerlevel10k installed"
else
    log_info "Powerlevel10k already installed, updating..."
    git -C "$P10K_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-autosuggestions
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ ! -d "$AUTOSUGGESTIONS_DIR" ]]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
    log_success "zsh-autosuggestions installed"
else
    log_info "zsh-autosuggestions already installed, updating..."
    git -C "$AUTOSUGGESTIONS_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-syntax-highlighting
SYNTAX_HL_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ ! -d "$SYNTAX_HL_DIR" ]]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTAX_HL_DIR"
    log_success "zsh-syntax-highlighting installed"
else
    log_info "zsh-syntax-highlighting already installed, updating..."
    git -C "$SYNTAX_HL_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-completions
COMPLETIONS_DIR="$ZSH_CUSTOM/plugins/zsh-completions"
if [[ ! -d "$COMPLETIONS_DIR" ]]; then
    log_info "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$COMPLETIONS_DIR"
    log_success "zsh-completions installed"
else
    log_info "zsh-completions already installed, updating..."
    git -C "$COMPLETIONS_DIR" pull --ff-only 2>/dev/null || true
fi

# Install fzf-tab (if fzf is available)
FZF_TAB_DIR="$ZSH_CUSTOM/plugins/fzf-tab"
if [[ ! -d "$FZF_TAB_DIR" ]]; then
    log_info "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    log_success "fzf-tab installed"
else
    log_info "fzf-tab already installed, updating..."
    git -C "$FZF_TAB_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-history-substring-search
HISTORY_SEARCH_DIR="$ZSH_CUSTOM/plugins/zsh-history-substring-search"
if [[ ! -d "$HISTORY_SEARCH_DIR" ]]; then
    log_info "Installing zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$HISTORY_SEARCH_DIR"
    log_success "zsh-history-substring-search installed"
else
    log_info "zsh-history-substring-search already installed, updating..."
    git -C "$HISTORY_SEARCH_DIR" pull --ff-only 2>/dev/null || true
fi

# Copy custom oh-my-zsh files if they exist
if [[ -d "$SHELL_DIR/oh-my-zsh-custom" ]]; then
    log_info "Restoring custom Oh-My-Zsh files..."
    for file in "$SHELL_DIR/oh-my-zsh-custom"/*.zsh; do
        if [[ -f "$file" ]]; then
            cp "$file" "$ZSH_CUSTOM/"
            log_info "Restored $(basename "$file")"
        fi
    done
fi

log_success "Shell plugins installed"
log_info "Note: Run 'source ~/.zshrc' or restart your terminal to activate"
