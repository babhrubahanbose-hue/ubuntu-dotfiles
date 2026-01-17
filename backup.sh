#!/usr/bin/env bash
# backup.sh - Export current Ubuntu desktop configuration
# Usage: ./backup.sh [--full|--packages|--configs|--gnome]

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

ensure_dirs

backup_apt_packages() {
    log_section "Backing up APT packages"

    # Get manually installed packages (excluding automatic dependencies)
    apt-mark showmanual | sort > "$PACKAGES_DIR/apt-packages.txt"
    log_success "Saved $(wc -l < "$PACKAGES_DIR/apt-packages.txt") APT packages"
}

backup_ppas() {
    log_section "Backing up APT sources (PPAs)"

    # Clear and recreate sources directory
    rm -rf "$SOURCES_DIR"/*

    # Copy source list files
    if [[ -d /etc/apt/sources.list.d ]]; then
        shopt -s nullglob
        for file in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
            if [[ -f "$file" ]]; then
                cp "$file" "$SOURCES_DIR/"
                log_info "Copied $(basename "$file")"
            fi
        done
        shopt -u nullglob
    fi

    # Copy signing keys
    mkdir -p "$SOURCES_DIR/keyrings"
    if [[ -d /etc/apt/keyrings ]]; then
        for key in /etc/apt/keyrings/*; do
            if [[ -f "$key" ]]; then
                cp "$key" "$SOURCES_DIR/keyrings/"
                log_info "Copied keyring $(basename "$key")"
            fi
        done
    fi

    # Also copy keys from /usr/share/keyrings that are referenced by our sources
    shopt -s nullglob
    for source_file in "$SOURCES_DIR"/*.list "$SOURCES_DIR"/*.sources; do
        if [[ -f "$source_file" ]]; then
            while IFS= read -r key_path; do
                if [[ -f "$key_path" ]]; then
                    cp "$key_path" "$SOURCES_DIR/keyrings/"
                    log_info "Copied referenced keyring $(basename "$key_path")"
                fi
            done < <(grep -oP '(?<=signed-by=)[^\s\]]+' "$source_file" 2>/dev/null || true)
        fi
    done
    shopt -u nullglob

    log_success "Backed up APT sources"
}

backup_homebrew() {
    log_section "Backing up Homebrew packages"

    if command_exists brew; then
        brew bundle dump --force --file="$PACKAGES_DIR/Brewfile"
        log_success "Saved Brewfile with $(grep -c '^' "$PACKAGES_DIR/Brewfile" || echo 0) entries"
    else
        log_warning "Homebrew not installed, skipping"
    fi
}

backup_snap() {
    log_section "Backing up Snap packages"

    if command_exists snap; then
        # List snaps with their confinement and channel info
        snap list 2>/dev/null | tail -n +2 | while read -r name version rev tracking publisher notes; do
            # Skip core snaps
            if [[ "$name" != "core"* && "$name" != "snapd" && "$name" != "bare" && "$name" != "gnome-"* ]]; then
                # Determine if classic
                if [[ "$notes" == *"classic"* ]]; then
                    echo "$name --classic"
                else
                    echo "$name"
                fi
            fi
        done > "$PACKAGES_DIR/snap-packages.txt"
        log_success "Saved $(wc -l < "$PACKAGES_DIR/snap-packages.txt") Snap packages"
    else
        log_warning "Snap not installed, skipping"
    fi
}

backup_gnome_extensions() {
    log_section "Backing up GNOME Shell extensions"

    local extensions_src="$HOME/.local/share/gnome-shell/extensions"

    if [[ -d "$extensions_src" ]]; then
        # List extension UUIDs
        ls -1 "$extensions_src" > "$PACKAGES_DIR/gnome-extensions.txt"

        # Copy extension directories
        rm -rf "$GNOME_DIR/extensions"/*
        for ext in "$extensions_src"/*; do
            if [[ -d "$ext" ]]; then
                cp -r "$ext" "$GNOME_DIR/extensions/"
                log_info "Copied extension $(basename "$ext")"
            fi
        done

        log_success "Backed up $(wc -l < "$PACKAGES_DIR/gnome-extensions.txt") extensions"
    else
        log_warning "No GNOME extensions found"
    fi
}

backup_dconf() {
    log_section "Backing up dconf/GNOME settings"

    if command_exists dconf; then
        dconf dump / > "$GNOME_DIR/dconf-full.conf"
        log_success "Saved full dconf database"

        # Also save specific sections for easier partial restores
        dconf dump /org/gnome/ > "$GNOME_DIR/dconf-gnome.conf" 2>/dev/null || true
        dconf dump /org/gtk/ > "$GNOME_DIR/dconf-gtk.conf" 2>/dev/null || true
    else
        log_warning "dconf not available, skipping"
    fi
}

backup_shell_config() {
    log_section "Backing up shell configuration"

    # Zsh config
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$SHELL_DIR/zshrc"
    [[ -f "$HOME/.p10k.zsh" ]] && cp "$HOME/.p10k.zsh" "$SHELL_DIR/p10k.zsh"
    [[ -f "$HOME/.zshenv" ]] && cp "$HOME/.zshenv" "$SHELL_DIR/zshenv"
    [[ -f "$HOME/.zprofile" ]] && cp "$HOME/.zprofile" "$SHELL_DIR/zprofile"

    # Bash config (as fallback)
    [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$SHELL_DIR/bashrc"
    [[ -f "$HOME/.bash_aliases" ]] && cp "$HOME/.bash_aliases" "$SHELL_DIR/bash_aliases"

    # Oh-My-Zsh custom files
    if [[ -d "$HOME/.oh-my-zsh/custom" ]]; then
        mkdir -p "$SHELL_DIR/oh-my-zsh-custom"
        # Copy custom aliases, themes, plugins references
        for file in "$HOME/.oh-my-zsh/custom"/*.zsh; do
            [[ -f "$file" ]] && cp "$file" "$SHELL_DIR/oh-my-zsh-custom/"
        done
    fi

    log_success "Backed up shell configs"
}

backup_terminal_configs() {
    log_section "Backing up terminal configurations"

    # Alacritty
    if [[ -d "$HOME/.config/alacritty" ]]; then
        cp -r "$HOME/.config/alacritty"/* "$TERMINALS_DIR/alacritty/" 2>/dev/null || true
        log_info "Backed up Alacritty config"
    fi

    # Kitty
    if [[ -d "$HOME/.config/kitty" ]]; then
        cp -r "$HOME/.config/kitty"/* "$TERMINALS_DIR/kitty/" 2>/dev/null || true
        log_info "Backed up Kitty config"
    fi

    # Terminator
    if [[ -d "$HOME/.config/terminator" ]]; then
        cp -r "$HOME/.config/terminator"/* "$TERMINALS_DIR/terminator/" 2>/dev/null || true
        log_info "Backed up Terminator config"
    fi

    log_success "Backed up terminal configs"
}

backup_editor_configs() {
    log_section "Backing up editor configurations"

    # Neovim
    if [[ -d "$HOME/.config/nvim" ]]; then
        rm -rf "$EDITORS_DIR/nvim"
        cp -r "$HOME/.config/nvim" "$EDITORS_DIR/"
        log_info "Backed up Neovim config"
    fi

    # Git config
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$EDITORS_DIR/gitconfig"

    # VS Code settings (if exists)
    local vscode_dir="$HOME/.config/Code/User"
    if [[ -d "$vscode_dir" ]]; then
        mkdir -p "$EDITORS_DIR/vscode"
        [[ -f "$vscode_dir/settings.json" ]] && cp "$vscode_dir/settings.json" "$EDITORS_DIR/vscode/"
        [[ -f "$vscode_dir/keybindings.json" ]] && cp "$vscode_dir/keybindings.json" "$EDITORS_DIR/vscode/"
        # Export extensions list
        if command_exists code; then
            code --list-extensions > "$EDITORS_DIR/vscode/extensions.txt" 2>/dev/null || true
        fi
        log_info "Backed up VS Code config"
    fi

    log_success "Backed up editor configs"
}

backup_app_configs() {
    log_section "Backing up application configurations"

    # Tmux
    [[ -f "$HOME/.tmux.conf" ]] && cp "$HOME/.tmux.conf" "$APPS_DIR/tmux.conf"
    [[ -d "$HOME/.tmux" ]] && cp -r "$HOME/.tmux" "$APPS_DIR/"

    # Bat
    if [[ -d "$HOME/.config/bat" ]]; then
        cp -r "$HOME/.config/bat"/* "$APPS_DIR/bat/" 2>/dev/null || true
    fi

    # Btop
    if [[ -d "$HOME/.config/btop" ]]; then
        cp -r "$HOME/.config/btop"/* "$APPS_DIR/btop/" 2>/dev/null || true
    fi

    # Ranger
    if [[ -d "$HOME/.config/ranger" ]]; then
        cp -r "$HOME/.config/ranger"/* "$APPS_DIR/ranger/" 2>/dev/null || true
    fi

    # Neofetch
    if [[ -d "$HOME/.config/neofetch" ]]; then
        cp -r "$HOME/.config/neofetch"/* "$APPS_DIR/neofetch/" 2>/dev/null || true
    fi

    log_success "Backed up application configs"
}

backup_theming() {
    log_section "Backing up theming"

    # GTK 3.0 settings
    if [[ -d "$HOME/.config/gtk-3.0" ]]; then
        cp -r "$HOME/.config/gtk-3.0"/* "$THEMING_DIR/gtk-3.0/" 2>/dev/null || true
    fi

    # GTK 4.0 settings
    if [[ -d "$HOME/.config/gtk-4.0" ]]; then
        cp -r "$HOME/.config/gtk-4.0"/* "$THEMING_DIR/gtk-4.0/" 2>/dev/null || true
    fi

    # Note: We don't copy full themes/icons as they're large
    # Instead, we'll record which ones are in use and download during restore

    # Record current theme settings
    if command_exists gsettings; then
        {
            echo "# Current theme settings (for reference)"
            echo "gtk-theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo 'unknown')"
            echo "icon-theme=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo 'unknown')"
            echo "cursor-theme=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || echo 'unknown')"
            echo "color-scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'unknown')"
        } > "$THEMING_DIR/current-theme.txt"
    fi

    log_success "Backed up theming configs"
}

backup_monitors() {
    log_section "Backing up monitor configuration"

    # GDM/GNOME monitors config
    [[ -f "$HOME/.config/monitors.xml" ]] && cp "$HOME/.config/monitors.xml" "$GNOME_DIR/"

    log_success "Backed up monitor config"
}

backup_autostart() {
    log_section "Backing up autostart entries"

    if [[ -d "$HOME/.config/autostart" ]]; then
        rm -rf "$AUTOSTART_DIR"/*
        cp -r "$HOME/.config/autostart"/* "$AUTOSTART_DIR/" 2>/dev/null || true
    fi

    log_success "Backed up autostart entries"
}

backup_wallpapers() {
    log_section "Backing up wallpapers"

    # Get current wallpaper path
    if command_exists gsettings; then
        local wallpaper
        wallpaper=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null | tr -d "'")
        wallpaper="${wallpaper#file://}"

        if [[ -f "$wallpaper" && "$wallpaper" == "$HOME"* ]]; then
            cp "$wallpaper" "$WALLPAPERS_DIR/"
            log_info "Copied current wallpaper: $(basename "$wallpaper")"
        fi

        # Also try dark mode wallpaper
        local wallpaper_dark
        wallpaper_dark=$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null | tr -d "'")
        wallpaper_dark="${wallpaper_dark#file://}"

        if [[ -f "$wallpaper_dark" && "$wallpaper_dark" == "$HOME"* && "$wallpaper_dark" != "$wallpaper" ]]; then
            cp "$wallpaper_dark" "$WALLPAPERS_DIR/"
            log_info "Copied dark mode wallpaper: $(basename "$wallpaper_dark")"
        fi
    fi

    log_success "Backed up wallpapers"
}

# Main backup function
run_full_backup() {
    log_section "Starting Full Backup"

    backup_apt_packages
    backup_ppas
    backup_homebrew
    backup_snap
    backup_gnome_extensions
    backup_dconf
    backup_shell_config
    backup_terminal_configs
    backup_editor_configs
    backup_app_configs
    backup_theming
    backup_monitors
    backup_autostart
    backup_wallpapers

    log_section "Backup Complete!"
    echo ""
    echo "Files saved to: $DOTFILES_DIR"
    echo ""
    echo "Next steps:"
    echo "  cd $DOTFILES_DIR"
    echo "  git add -A && git commit -m \"Backup \$(date +%Y-%m-%d)\""
    echo "  git push"
}

# Parse arguments
case "${1:-}" in
    --packages)
        backup_apt_packages
        backup_ppas
        backup_homebrew
        backup_snap
        ;;
    --configs)
        backup_shell_config
        backup_terminal_configs
        backup_editor_configs
        backup_app_configs
        ;;
    --gnome)
        backup_gnome_extensions
        backup_dconf
        backup_theming
        backup_monitors
        ;;
    --full|"")
        run_full_backup
        ;;
    *)
        echo "Usage: $0 [--full|--packages|--configs|--gnome]"
        echo ""
        echo "Options:"
        echo "  --full      Full backup (default)"
        echo "  --packages  Backup only package lists"
        echo "  --configs   Backup only config files"
        echo "  --gnome     Backup only GNOME settings"
        exit 1
        ;;
esac
