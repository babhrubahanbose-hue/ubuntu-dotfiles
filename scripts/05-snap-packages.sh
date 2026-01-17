#!/usr/bin/env bash
# 05-snap-packages.sh - Install Snap packages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

SNAP_LIST="$PACKAGES_DIR/snap-packages.txt"

if ! command_exists snap; then
    log_info "Installing snapd..."
    sudo apt-get install -y snapd
fi

if [[ ! -f "$SNAP_LIST" ]]; then
    log_warning "No snap-packages.txt found, skipping"
    exit 0
fi

log_info "Installing Snap packages..."

INSTALLED_COUNT=0
FAILED_PACKAGES=()

while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Parse package name and flags
    read -r package flags <<< "$line"

    log_info "Installing $package..."

    if [[ "$flags" == "--classic" ]]; then
        if sudo snap install "$package" --classic 2>/dev/null; then
            ((INSTALLED_COUNT++)) || true
        else
            FAILED_PACKAGES+=("$package")
        fi
    else
        if sudo snap install "$package" 2>/dev/null; then
            ((INSTALLED_COUNT++)) || true
        else
            FAILED_PACKAGES+=("$package")
        fi
    fi
done < "$SNAP_LIST"

log_success "Installed $INSTALLED_COUNT Snap packages"

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    log_warning "Failed to install:"
    printf '  %s\n' "${FAILED_PACKAGES[@]}"
fi
