#!/usr/bin/env bash
# 40-gnome-extensions.sh - Install and enable GNOME Shell extensions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

EXTENSIONS_SRC="$GNOME_DIR/extensions"
EXTENSIONS_DEST="$HOME/.local/share/gnome-shell/extensions"
EXTENSIONS_LIST="$PACKAGES_DIR/gnome-extensions.txt"

# Create extensions directory
mkdir -p "$EXTENSIONS_DEST"

# Install gnome-shell-extension-prefs if not present
ensure_package gnome-shell-extension-prefs 2>/dev/null || true

install_from_backup() {
    log_section "Installing GNOME Extensions from Backup"

    if [[ ! -d "$EXTENSIONS_SRC" ]] || [[ -z "$(ls -A "$EXTENSIONS_SRC" 2>/dev/null)" ]]; then
        log_warning "No extension backups found in $EXTENSIONS_SRC"
        return
    fi

    local count=0
    for ext_dir in "$EXTENSIONS_SRC"/*; do
        if [[ -d "$ext_dir" ]]; then
            local ext_uuid=$(basename "$ext_dir")
            local dest="$EXTENSIONS_DEST/$ext_uuid"

            # Remove existing
            [[ -d "$dest" ]] && rm -rf "$dest"

            # Copy extension
            cp -r "$ext_dir" "$EXTENSIONS_DEST/"
            log_info "Installed: $ext_uuid"
            ((count++)) || true
        fi
    done

    log_success "Installed $count extensions from backup"
}

enable_extensions() {
    log_section "Enabling Extensions"

    if ! command_exists gnome-extensions; then
        log_warning "gnome-extensions command not available, skipping enable"
        return
    fi

    if [[ ! -f "$EXTENSIONS_LIST" ]]; then
        log_warning "No extensions list found"
        return
    fi

    local enabled=0
    while IFS= read -r uuid; do
        [[ -z "$uuid" || "$uuid" == \#* ]] && continue

        if gnome-extensions enable "$uuid" 2>/dev/null; then
            log_info "Enabled: $uuid"
            ((enabled++)) || true
        else
            log_warning "Failed to enable: $uuid"
        fi
    done < "$EXTENSIONS_LIST"

    log_success "Enabled $enabled extensions"
}

install_from_gnome_extensions_website() {
    # Optional: Install extensions from extensions.gnome.org
    # This requires browser integration which may not be available

    log_info "To install additional extensions:"
    log_info "1. Visit https://extensions.gnome.org/"
    log_info "2. Install the browser integration"
    log_info "3. Toggle extensions on the website"
}

# Main installation
install_from_backup

# Try to enable extensions
if confirm "Enable installed extensions now?" "y"; then
    enable_extensions
fi

log_section "GNOME Extensions Installation Complete"
echo ""
log_info "Note: You may need to log out and back in for extensions to appear"
log_info "Use 'gnome-extensions list' to see installed extensions"
log_info "Use 'gnome-tweaks' or Extensions app to manage extensions"
