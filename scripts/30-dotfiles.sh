#!/usr/bin/env bash
# 30-dotfiles.sh - Restore all configuration files (shell, terminals, editors, apps)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

# Mode: 'symlink' or 'copy'
# Symlinks are easier to update but require the dotfiles repo to stay in place
LINK_MODE="${DOTFILES_LINK_MODE:-symlink}"

link_or_copy() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_warning "Source not found: $source"
        return 1
    fi

    if [[ "$LINK_MODE" == "symlink" ]]; then
        create_symlink "$source" "$target"
    else
        copy_with_backup "$source" "$target"
    fi
}

restore_shell_configs() {
    log_section "Restoring Shell Configurations"

    # Zsh config
    [[ -f "$SHELL_DIR/zshrc" ]] && link_or_copy "$SHELL_DIR/zshrc" "$HOME/.zshrc"
    [[ -f "$SHELL_DIR/p10k.zsh" ]] && link_or_copy "$SHELL_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    [[ -f "$SHELL_DIR/zshenv" ]] && link_or_copy "$SHELL_DIR/zshenv" "$HOME/.zshenv"
    [[ -f "$SHELL_DIR/zprofile" ]] && link_or_copy "$SHELL_DIR/zprofile" "$HOME/.zprofile"

    # Bash config (for fallback/compatibility)
    [[ -f "$SHELL_DIR/bashrc" ]] && link_or_copy "$SHELL_DIR/bashrc" "$HOME/.bashrc"
    [[ -f "$SHELL_DIR/bash_aliases" ]] && link_or_copy "$SHELL_DIR/bash_aliases" "$HOME/.bash_aliases"

    log_success "Shell configs restored"
}

restore_terminal_configs() {
    log_section "Restoring Terminal Configurations"

    # Alacritty
    if [[ -d "$TERMINALS_DIR/alacritty" ]] && [[ -n "$(ls -A "$TERMINALS_DIR/alacritty" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/alacritty"
        for file in "$TERMINALS_DIR/alacritty"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/alacritty/$(basename "$file")"
        done
        log_info "Restored Alacritty config"
    fi

    # Kitty
    if [[ -d "$TERMINALS_DIR/kitty" ]] && [[ -n "$(ls -A "$TERMINALS_DIR/kitty" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/kitty"
        for file in "$TERMINALS_DIR/kitty"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/kitty/$(basename "$file")"
        done
        log_info "Restored Kitty config"
    fi

    # Terminator
    if [[ -d "$TERMINALS_DIR/terminator" ]] && [[ -n "$(ls -A "$TERMINALS_DIR/terminator" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/terminator"
        for file in "$TERMINALS_DIR/terminator"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/terminator/$(basename "$file")"
        done
        log_info "Restored Terminator config"
    fi

    log_success "Terminal configs restored"
}

restore_editor_configs() {
    log_section "Restoring Editor Configurations"

    # Neovim
    if [[ -d "$EDITORS_DIR/nvim" ]]; then
        log_info "Restoring Neovim config..."
        mkdir -p "$HOME/.config"

        # For neovim, we typically want to copy rather than symlink
        # because lazy.nvim and other plugin managers write to this directory
        if [[ -d "$HOME/.config/nvim" ]]; then
            local backup="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
            log_warning "Backing up existing nvim config to $backup"
            mv "$HOME/.config/nvim" "$backup"
        fi

        cp -r "$EDITORS_DIR/nvim" "$HOME/.config/"
        log_info "Restored Neovim config"
    fi

    # Git config
    if [[ -f "$EDITORS_DIR/gitconfig" ]]; then
        link_or_copy "$EDITORS_DIR/gitconfig" "$HOME/.gitconfig"
        log_info "Restored Git config"
    fi

    # VS Code
    if [[ -d "$EDITORS_DIR/vscode" ]]; then
        local vscode_dir="$HOME/.config/Code/User"
        mkdir -p "$vscode_dir"

        [[ -f "$EDITORS_DIR/vscode/settings.json" ]] && \
            link_or_copy "$EDITORS_DIR/vscode/settings.json" "$vscode_dir/settings.json"
        [[ -f "$EDITORS_DIR/vscode/keybindings.json" ]] && \
            link_or_copy "$EDITORS_DIR/vscode/keybindings.json" "$vscode_dir/keybindings.json"

        # Install extensions if code is available
        if command_exists code && [[ -f "$EDITORS_DIR/vscode/extensions.txt" ]]; then
            log_info "Installing VS Code extensions..."
            while IFS= read -r ext; do
                code --install-extension "$ext" 2>/dev/null || true
            done < "$EDITORS_DIR/vscode/extensions.txt"
        fi

        log_info "Restored VS Code config"
    fi

    log_success "Editor configs restored"
}

restore_app_configs() {
    log_section "Restoring Application Configurations"

    # Tmux
    [[ -f "$APPS_DIR/tmux.conf" ]] && link_or_copy "$APPS_DIR/tmux.conf" "$HOME/.tmux.conf"
    if [[ -d "$APPS_DIR/.tmux" ]]; then
        mkdir -p "$HOME/.tmux"
        cp -r "$APPS_DIR/.tmux"/* "$HOME/.tmux/" 2>/dev/null || true
    fi

    # Bat
    if [[ -d "$APPS_DIR/bat" ]] && [[ -n "$(ls -A "$APPS_DIR/bat" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/bat"
        for file in "$APPS_DIR/bat"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/bat/$(basename "$file")"
        done
        # Rebuild bat cache
        command_exists bat && bat cache --build 2>/dev/null || true
        log_info "Restored Bat config"
    fi

    # Btop
    if [[ -d "$APPS_DIR/btop" ]] && [[ -n "$(ls -A "$APPS_DIR/btop" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/btop"
        for file in "$APPS_DIR/btop"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/btop/$(basename "$file")"
        done
        log_info "Restored Btop config"
    fi

    # Ranger
    if [[ -d "$APPS_DIR/ranger" ]] && [[ -n "$(ls -A "$APPS_DIR/ranger" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/ranger"
        for file in "$APPS_DIR/ranger"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/ranger/$(basename "$file")"
        done
        log_info "Restored Ranger config"
    fi

    # Neofetch
    if [[ -d "$APPS_DIR/neofetch" ]] && [[ -n "$(ls -A "$APPS_DIR/neofetch" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/neofetch"
        for file in "$APPS_DIR/neofetch"/*; do
            [[ -e "$file" ]] && link_or_copy "$file" "$HOME/.config/neofetch/$(basename "$file")"
        done
        log_info "Restored Neofetch config"
    fi

    log_success "Application configs restored"
}

restore_wallpapers() {
    log_section "Restoring Wallpapers"

    if [[ -d "$WALLPAPERS_DIR" ]] && [[ -n "$(ls -A "$WALLPAPERS_DIR" 2>/dev/null)" ]]; then
        local dest="$HOME/Pictures/Wallpapers"
        mkdir -p "$dest"

        for wallpaper in "$WALLPAPERS_DIR"/*; do
            if [[ -f "$wallpaper" ]]; then
                cp "$wallpaper" "$dest/"
                log_info "Copied $(basename "$wallpaper")"
            fi
        done

        # Set first wallpaper found
        local first_wallpaper
        first_wallpaper=$(ls -1 "$dest"/* 2>/dev/null | head -1)
        if [[ -n "$first_wallpaper" ]] && command_exists gsettings; then
            gsettings set org.gnome.desktop.background picture-uri "file://$first_wallpaper" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$first_wallpaper" 2>/dev/null || true
            log_info "Set wallpaper to $(basename "$first_wallpaper")"
        fi

        log_success "Wallpapers restored"
    else
        log_info "No wallpapers to restore"
    fi
}

restore_autostart() {
    log_section "Restoring Autostart Entries"

    if [[ -d "$AUTOSTART_DIR" ]] && [[ -n "$(ls -A "$AUTOSTART_DIR" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/autostart"

        for entry in "$AUTOSTART_DIR"/*; do
            if [[ -f "$entry" ]]; then
                cp "$entry" "$HOME/.config/autostart/"
                log_info "Restored $(basename "$entry")"
            fi
        done

        log_success "Autostart entries restored"
    else
        log_info "No autostart entries to restore"
    fi
}

restore_monitors() {
    log_section "Restoring Monitor Configuration"

    if [[ -f "$GNOME_DIR/monitors.xml" ]]; then
        mkdir -p "$HOME/.config"
        cp "$GNOME_DIR/monitors.xml" "$HOME/.config/"
        log_success "Monitor config restored"
    else
        log_info "No monitor config to restore"
    fi
}

# Main restoration
log_info "Using $LINK_MODE mode for dotfiles"
log_info "(Set DOTFILES_LINK_MODE=copy to use copy mode instead of symlinks)"
echo ""

restore_shell_configs
restore_terminal_configs
restore_editor_configs
restore_app_configs
restore_wallpapers
restore_autostart
restore_monitors

log_section "Dotfiles Restoration Complete"
log_info "Run 'source ~/.zshrc' or restart your terminal to apply shell changes"
