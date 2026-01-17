#!/usr/bin/env bash
# 02-ppas-setup.sh - Set up APT repositories (PPAs) and signing keys

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

KEYRINGS_DIR="$SOURCES_DIR/keyrings"

# Ensure keyrings directory exists in system
sudo mkdir -p /etc/apt/keyrings

# Install signing keys
if [[ -d "$KEYRINGS_DIR" ]]; then
    log_info "Installing signing keys..."
    for key in "$KEYRINGS_DIR"/*; do
        if [[ -f "$key" ]]; then
            keyname=$(basename "$key")
            sudo cp "$key" /etc/apt/keyrings/
            sudo chmod 644 "/etc/apt/keyrings/$keyname"
            log_info "Installed key: $keyname"
        fi
    done
fi

# Copy source list files
log_info "Setting up APT sources..."
shopt -s nullglob
for source_file in "$SOURCES_DIR"/*.list "$SOURCES_DIR"/*.sources; do
    if [[ -f "$source_file" ]]; then
        filename=$(basename "$source_file")
        sudo cp "$source_file" /etc/apt/sources.list.d/
        sudo chmod 644 "/etc/apt/sources.list.d/$filename"
        log_info "Added source: $filename"
    fi
done
shopt -u nullglob

# Common PPAs that might be needed (will skip if already added)
add_common_ppas() {
    # These are popular PPAs - adjust as needed

    # Brave Browser
    if ! grep -r "brave-browser" /etc/apt/sources.list.d/ &>/dev/null; then
        log_info "Adding Brave Browser repository..."
        sudo curl -fsSLo /etc/apt/keyrings/brave-browser-archive-keyring.gpg \
            https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
            sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null 2>/dev/null || true
    fi

    # Google Chrome
    if ! grep -r "google-chrome" /etc/apt/sources.list.d/ &>/dev/null; then
        log_info "Adding Google Chrome repository..."
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | \
            sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
            sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null 2>/dev/null || true
    fi
}

# Only add common PPAs if explicitly requested or if no sources were copied
if [[ ! -d "$SOURCES_DIR" ]] || [[ -z "$(ls -A "$SOURCES_DIR" 2>/dev/null)" ]]; then
    log_info "No saved sources found, adding common PPAs..."
    add_common_ppas
fi

log_info "Updating package lists with new repositories..."
sudo apt-get update

log_success "APT repositories configured"
