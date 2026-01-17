#!/usr/bin/env bash
# 21-themes-icons.sh - Install GTK themes, icon packs, and cursors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

THEMES_DIR="$HOME/.local/share/themes"
ICONS_DIR="$HOME/.local/share/icons"

mkdir -p "$THEMES_DIR" "$ICONS_DIR"

install_nordic_theme() {
    log_info "Installing Nordic GTK theme..."

    local theme_dir="$THEMES_DIR/Nordic"

    if [[ -d "$theme_dir" ]]; then
        log_info "Nordic theme already installed, updating..."
        rm -rf "$theme_dir"
    fi

    local temp_dir
    temp_dir=$(mktemp -d)

    git clone --depth=1 https://github.com/EliverLara/Nordic.git "$temp_dir/Nordic"

    # Copy theme to themes directory
    cp -r "$temp_dir/Nordic" "$THEMES_DIR/"

    # Also install variants
    for variant in Nordic-darker Nordic-bluish-accent Nordic-Polar; do
        if [[ -d "$temp_dir/Nordic/$variant" ]]; then
            cp -r "$temp_dir/Nordic/$variant" "$THEMES_DIR/"
        fi
    done

    rm -rf "$temp_dir"

    log_success "Nordic theme installed"
}

install_papirus_icons() {
    log_info "Installing Papirus icon theme..."

    # Check if already installed via apt
    if dpkg -l | grep -q papirus-icon-theme; then
        log_info "Papirus already installed via apt"
        return
    fi

    # Try apt first
    if sudo apt-get install -y papirus-icon-theme 2>/dev/null; then
        log_success "Papirus installed via apt"
        return
    fi

    # Manual installation
    local temp_dir
    temp_dir=$(mktemp -d)

    log_info "Downloading Papirus icons..."
    wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$ICONS_DIR" sh

    log_success "Papirus icons installed"
}

install_bibata_cursors() {
    log_info "Installing Bibata cursor theme..."

    local cursor_name="Bibata-Modern-Classic"

    if [[ -d "$ICONS_DIR/$cursor_name" ]]; then
        log_info "Bibata cursors already installed"
        return
    fi

    local temp_dir
    temp_dir=$(mktemp -d)

    # Download latest Bibata cursors
    local url="https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz"

    if curl -fsSL "$url" -o "$temp_dir/bibata.tar.xz"; then
        tar -xf "$temp_dir/bibata.tar.xz" -C "$ICONS_DIR/"
        log_success "Bibata cursors installed"
    else
        log_warning "Failed to download Bibata cursors"
    fi

    rm -rf "$temp_dir"
}

apply_themes() {
    log_info "Applying themes via gsettings..."

    if ! command_exists gsettings; then
        log_warning "gsettings not available, skipping theme application"
        return
    fi

    # Apply theme settings
    gsettings set org.gnome.desktop.interface gtk-theme "Nordic" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true

    # Window manager theme (for GNOME on X11)
    gsettings set org.gnome.desktop.wm.preferences theme "Nordic" 2>/dev/null || true

    log_success "Theme settings applied"
}

# Restore GTK configs if they exist
restore_gtk_configs() {
    log_info "Restoring GTK configuration files..."

    # GTK 3
    if [[ -d "$THEMING_DIR/gtk-3.0" ]] && [[ -n "$(ls -A "$THEMING_DIR/gtk-3.0" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/gtk-3.0"
        cp -r "$THEMING_DIR/gtk-3.0"/* "$HOME/.config/gtk-3.0/"
        log_info "Restored GTK 3.0 config"
    fi

    # GTK 4
    if [[ -d "$THEMING_DIR/gtk-4.0" ]] && [[ -n "$(ls -A "$THEMING_DIR/gtk-4.0" 2>/dev/null)" ]]; then
        mkdir -p "$HOME/.config/gtk-4.0"
        cp -r "$THEMING_DIR/gtk-4.0"/* "$HOME/.config/gtk-4.0/"
        log_info "Restored GTK 4.0 config"
    fi
}

# Main installation
log_section "Installing Themes and Icons"

install_nordic_theme
install_papirus_icons
install_bibata_cursors
restore_gtk_configs

# Ask before applying (might overwrite user preferences)
if confirm "Apply Nordic theme, Papirus icons, and Bibata cursors?"; then
    apply_themes
else
    log_info "Skipping theme application. You can apply manually via GNOME Tweaks."
fi

log_success "Themes and icons installation complete"
