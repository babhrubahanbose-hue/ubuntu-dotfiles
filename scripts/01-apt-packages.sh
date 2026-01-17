#!/usr/bin/env bash
# 01-apt-packages.sh - Install APT packages from saved list

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

APT_LIST="$PACKAGES_DIR/apt-packages.txt"

if [[ ! -f "$APT_LIST" ]]; then
    log_warning "No apt-packages.txt found, skipping"
    exit 0
fi

log_info "Installing APT packages from list..."

# Filter out packages that might cause issues or don't exist
# (packages from PPAs will be installed after PPAs are set up)
FAILED_PACKAGES=()
INSTALLED_COUNT=0
TOTAL_COUNT=$(wc -l < "$APT_LIST")

while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" == \#* ]] && continue

    # Check if package is available
    if apt-cache show "$package" &>/dev/null; then
        if sudo apt-get install -y "$package" 2>/dev/null; then
            ((INSTALLED_COUNT++)) || true
        else
            FAILED_PACKAGES+=("$package")
        fi
    else
        FAILED_PACKAGES+=("$package (not found)")
    fi
done < "$APT_LIST"

log_success "Installed $INSTALLED_COUNT/$TOTAL_COUNT packages"

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    log_warning "Failed packages (may need PPAs or manual install):"
    printf '  %s\n' "${FAILED_PACKAGES[@]}"
fi
