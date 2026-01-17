#!/usr/bin/env bash
# 00-system-update.sh - Update system and install essential packages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_not_root

log_info "Updating package lists..."
sudo apt-get update

log_info "Upgrading installed packages..."
sudo apt-get upgrade -y

log_info "Installing essential build tools..."
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

log_success "System updated and essentials installed"
