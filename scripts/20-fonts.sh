#!/usr/bin/env bash
# 20-fonts.sh - Install Nerd Fonts and other fonts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

# Install fontconfig for fc-cache
ensure_package fontconfig

install_nerd_font() {
    local font_name="$1"
    local font_dir="$FONTS_DIR/$font_name"

    if [[ -d "$font_dir" ]] && [[ -n "$(ls -A "$font_dir" 2>/dev/null)" ]]; then
        log_info "$font_name already installed, skipping"
        return
    fi

    log_info "Downloading $font_name Nerd Font..."

    local temp_dir
    temp_dir=$(mktemp -d)
    local zip_file="$temp_dir/$font_name.zip"

    # Download from Nerd Fonts releases
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font_name.zip"

    if curl -fsSL "$url" -o "$zip_file"; then
        mkdir -p "$font_dir"
        unzip -q -o "$zip_file" -d "$font_dir"
        # Remove Windows-specific fonts
        find "$font_dir" -name "*Windows Compatible*" -delete 2>/dev/null || true
        log_success "Installed $font_name"
    else
        log_warning "Failed to download $font_name"
    fi

    rm -rf "$temp_dir"
}

# Install required Nerd Fonts
log_section "Installing Nerd Fonts"

# JetBrainsMono - main coding font
install_nerd_font "JetBrainsMono"

# Additional fonts that are commonly used
install_nerd_font "FiraCode"
install_nerd_font "Hack"
install_nerd_font "Meslo"

# Install MesloLGS NF specifically for Powerlevel10k
log_info "Installing MesloLGS NF for Powerlevel10k..."
MESLO_P10K_DIR="$FONTS_DIR/MesloLGS-NF"
mkdir -p "$MESLO_P10K_DIR"

for style in Regular Bold Italic "Bold Italic"; do
    local filename="MesloLGS NF ${style}.ttf"
    local url_style="${style// /%20}"
    local url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${url_style}.ttf"

    if [[ ! -f "$MESLO_P10K_DIR/$filename" ]]; then
        curl -fsSL "$url" -o "$MESLO_P10K_DIR/$filename" 2>/dev/null || true
    fi
done

# Refresh font cache
log_info "Rebuilding font cache..."
fc-cache -f

log_success "Fonts installed"
log_info "Available Nerd Fonts:"
fc-list | grep -i "nerd\|jetbrains\|meslo" | cut -d: -f2 | sort -u | head -20

log_info ""
log_info "Note: You may need to select these fonts in your terminal preferences"
log_info "Recommended: 'JetBrainsMono Nerd Font' or 'MesloLGS NF'"
