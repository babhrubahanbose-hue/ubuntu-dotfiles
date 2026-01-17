#!/usr/bin/env bash
# restore.sh - Restore Ubuntu desktop configuration from backup
# Usage: ./restore.sh [--full|--only PHASE|--from PHASE|--list]

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

check_not_root

# Define phases and their scripts
declare -A PHASES=(
    [1]="Base System (apt update, core packages)"
    [2]="PPAs and Repositories"
    [3]="Homebrew Installation"
    [4]="Homebrew Packages"
    [5]="Snap Packages"
    [6]="Shell Setup (zsh, Oh-My-Zsh)"
    [7]="Shell Plugins (p10k, zsh-plugins)"
    [8]="Fonts"
    [9]="Themes and Icons"
    [10]="Dotfiles and Configs"
    [11]="GNOME Extensions"
    [12]="GNOME Settings"
)

declare -A PHASE_SCRIPTS=(
    [1]="00-system-update.sh 01-apt-packages.sh"
    [2]="02-ppas-setup.sh"
    [3]="03-homebrew.sh"
    [4]="04-brew-packages.sh"
    [5]="05-snap-packages.sh"
    [6]="10-shell-setup.sh"
    [7]="11-shell-plugins.sh"
    [8]="20-fonts.sh"
    [9]="21-themes-icons.sh"
    [10]="30-dotfiles.sh"
    [11]="40-gnome-extensions.sh"
    [12]="41-gnome-settings.sh"
)

list_phases() {
    echo "Available phases:"
    echo ""
    for i in $(seq 1 12); do
        echo "  $i. ${PHASES[$i]}"
    done
    echo ""
}

run_phase() {
    local phase="$1"
    local scripts="${PHASE_SCRIPTS[$phase]}"

    log_section "Phase $phase: ${PHASES[$phase]}"

    for script in $scripts; do
        local script_path="$SCRIPT_DIR/scripts/$script"
        if [[ -f "$script_path" ]]; then
            run_script "$script_path"
        else
            log_warning "Script not found: $script_path"
        fi
    done
}

run_from_phase() {
    local start_phase="$1"

    for i in $(seq "$start_phase" 12); do
        run_phase "$i"
    done
}

run_only_phase() {
    local phase="$1"

    if [[ -z "${PHASES[$phase]:-}" ]]; then
        log_error "Invalid phase: $phase"
        list_phases
        exit 1
    fi

    run_phase "$phase"
}

run_full_restore() {
    log_section "Ubuntu Desktop Full Restore"
    echo ""
    echo "This will install and configure the following:"
    echo ""
    list_phases
    echo ""

    if ! confirm "Proceed with full restore?"; then
        log_info "Restore cancelled"
        exit 0
    fi

    for i in $(seq 1 12); do
        run_phase "$i"
    done

    log_section "Restore Complete!"
    echo ""
    echo "Please log out and log back in to apply all changes."
    echo ""
    echo "If you experience any issues:"
    echo "  - Run 'source ~/.zshrc' to reload shell config"
    echo "  - Run 'gnome-shell --replace &' (X11) or log out (Wayland) for GNOME changes"
    echo ""
}

run_interactive() {
    log_section "Interactive Restore"
    echo ""
    list_phases
    echo ""

    while true; do
        read -rp "Enter phase number to run (1-12), 'all' for full restore, or 'q' to quit: " choice

        case "$choice" in
            [1-9]|1[0-2])
                run_only_phase "$choice"
                ;;
            all)
                run_full_restore
                break
                ;;
            q|quit|exit)
                log_info "Exiting"
                break
                ;;
            *)
                echo "Invalid choice. Enter 1-12, 'all', or 'q'"
                ;;
        esac
    done
}

# Print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --full          Run full restore (all phases)"
    echo "  --only PHASE    Run only specified phase (1-12)"
    echo "  --from PHASE    Run from specified phase to end"
    echo "  --list          List available phases"
    echo "  --interactive   Interactive mode (choose phases)"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --full           # Full restore"
    echo "  $0 --only 6         # Only install shell (zsh, Oh-My-Zsh)"
    echo "  $0 --from 8         # Run from fonts phase onwards"
    echo "  $0 --interactive    # Choose what to install"
    echo ""
}

# Parse arguments
case "${1:-}" in
    --full)
        run_full_restore
        ;;
    --only)
        if [[ -z "${2:-}" ]]; then
            log_error "Please specify a phase number"
            usage
            exit 1
        fi
        run_only_phase "$2"
        ;;
    --from)
        if [[ -z "${2:-}" ]]; then
            log_error "Please specify a starting phase number"
            usage
            exit 1
        fi
        run_from_phase "$2"
        ;;
    --list)
        list_phases
        ;;
    --interactive|-i)
        run_interactive
        ;;
    -h|--help)
        usage
        ;;
    "")
        run_interactive
        ;;
    *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
esac
