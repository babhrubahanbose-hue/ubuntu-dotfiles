#!/usr/bin/env bash
# utils.sh - Shared functions for backup and restore scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check if running as root (some scripts need sudo)
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should NOT be run as root. Use sudo when needed."
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install package if not present
ensure_package() {
    local pkg="$1"
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        log_info "Installing $pkg..."
        sudo apt-get install -y "$pkg"
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Backup existing file if it's not a symlink
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi

    # Remove existing symlink
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    # Create symlink
    ln -sf "$source" "$target"
    log_success "Linked $target -> $source"
}

# Copy file/directory with backup
copy_with_backup() {
    local source="$1"
    local target="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Backup existing file if different
    if [[ -e "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi

    # Copy
    cp -r "$source" "$target"
    log_success "Copied $source to $target"
}

# Ask for confirmation
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        local options="[Y/n]"
    else
        local options="[y/N]"
    fi

    read -rp "$prompt $options " response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

# Run script with error handling
run_script() {
    local script="$1"
    local name=$(basename "$script" .sh)

    log_section "Running: $name"

    if [[ -x "$script" ]]; then
        if "$script"; then
            log_success "Completed: $name"
            return 0
        else
            log_error "Failed: $name"
            return 1
        fi
    else
        log_error "Script not found or not executable: $script"
        return 1
    fi
}

# Get the dotfiles directory (resolves symlinks)
get_dotfiles_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Go up one level from scripts/
    dirname "$script_dir"
}

DOTFILES_DIR="$(get_dotfiles_dir)"

# Export common paths
export DOTFILES_DIR
export PACKAGES_DIR="$DOTFILES_DIR/packages"
export SOURCES_DIR="$DOTFILES_DIR/sources"
export GNOME_DIR="$DOTFILES_DIR/gnome"
export SHELL_DIR="$DOTFILES_DIR/shell"
export TERMINALS_DIR="$DOTFILES_DIR/terminals"
export EDITORS_DIR="$DOTFILES_DIR/editors"
export APPS_DIR="$DOTFILES_DIR/apps"
export THEMING_DIR="$DOTFILES_DIR/theming"
export WALLPAPERS_DIR="$DOTFILES_DIR/wallpapers"
export AUTOSTART_DIR="$DOTFILES_DIR/autostart"

# Ensure directories exist
ensure_dirs() {
    mkdir -p "$PACKAGES_DIR" "$SOURCES_DIR" "$GNOME_DIR/extensions" \
             "$SHELL_DIR" "$TERMINALS_DIR"/{alacritty,kitty,terminator} \
             "$EDITORS_DIR/nvim" "$APPS_DIR"/{bat,btop,ranger,neofetch} \
             "$THEMING_DIR"/{themes,gtk-3.0,gtk-4.0} "$WALLPAPERS_DIR" "$AUTOSTART_DIR"
}
