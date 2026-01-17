#!/usr/bin/env bash
# 41-gnome-settings.sh - Restore GNOME/dconf settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

DCONF_FILE="$GNOME_DIR/dconf-full.conf"
DCONF_GNOME="$GNOME_DIR/dconf-gnome.conf"

if ! command_exists dconf; then
    log_error "dconf not found. Install with: sudo apt install dconf-cli"
    exit 1
fi

show_current_theme() {
    log_info "Current theme settings:"
    echo "  GTK Theme: $(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo 'unknown')"
    echo "  Icon Theme: $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo 'unknown')"
    echo "  Cursor Theme: $(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || echo 'unknown')"
    echo ""
}

restore_full_dconf() {
    log_section "Restoring Full dconf Database"

    if [[ ! -f "$DCONF_FILE" ]]; then
        log_warning "No dconf backup found at $DCONF_FILE"
        return 1
    fi

    log_warning "This will restore ALL GNOME settings including:"
    echo "  - Desktop preferences"
    echo "  - Keyboard shortcuts"
    echo "  - Extension settings"
    echo "  - Theme settings"
    echo "  - Privacy settings"
    echo "  - And more..."
    echo ""

    show_current_theme

    if ! confirm "Restore all dconf settings? This may overwrite current preferences." "n"; then
        log_info "Skipping full dconf restore"
        return 0
    fi

    # Create a backup of current settings first
    local backup="$GNOME_DIR/dconf-backup-$(date +%Y%m%d_%H%M%S).conf"
    dconf dump / > "$backup"
    log_info "Current settings backed up to: $backup"

    # Restore settings
    dconf load / < "$DCONF_FILE"
    log_success "Full dconf settings restored"

    return 0
}

restore_gnome_only() {
    log_section "Restoring GNOME-specific Settings"

    if [[ ! -f "$DCONF_GNOME" ]]; then
        log_warning "No GNOME dconf backup found"
        return 1
    fi

    if ! confirm "Restore GNOME desktop settings?" "y"; then
        log_info "Skipping GNOME settings restore"
        return 0
    fi

    dconf load /org/gnome/ < "$DCONF_GNOME"
    log_success "GNOME settings restored"
}

restore_selective() {
    log_section "Selective Settings Restore"

    echo "Choose what to restore:"
    echo "  1) Full dconf database (all settings)"
    echo "  2) GNOME desktop settings only"
    echo "  3) Skip dconf restore"
    echo ""

    read -rp "Enter choice [1-3]: " choice

    case "$choice" in
        1)
            restore_full_dconf
            ;;
        2)
            restore_gnome_only
            ;;
        3)
            log_info "Skipping dconf restore"
            ;;
        *)
            log_warning "Invalid choice, skipping"
            ;;
    esac
}

apply_recommended_settings() {
    log_section "Applying Recommended Settings"

    # These are non-destructive quality-of-life settings

    # Show battery percentage
    gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null || true

    # Enable dark mode
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

    # Show weekday in clock
    gsettings set org.gnome.desktop.interface clock-show-weekday true 2>/dev/null || true

    # Enable minimize/maximize buttons
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' 2>/dev/null || true

    # Disable hot corner
    gsettings set org.gnome.desktop.interface enable-hot-corners false 2>/dev/null || true

    # Set font hinting
    gsettings set org.gnome.desktop.interface font-hinting 'slight' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba' 2>/dev/null || true

    log_success "Recommended settings applied"
}

# Main
if [[ -f "$DCONF_FILE" ]]; then
    restore_selective
else
    log_warning "No dconf backup found"
    if confirm "Apply recommended GNOME settings instead?" "y"; then
        apply_recommended_settings
    fi
fi

log_section "GNOME Settings Complete"
log_info "Some changes may require logging out and back in"
