#!/bin/bash
# Install GTK themes
# This runs once before chezmoi applies dotfiles

set -e

echo "==> Installing GTK themes..."

THEMES_DIR="$HOME/.themes"
mkdir -p "$THEMES_DIR"

# Install Nordic theme
if [ ! -d "$THEMES_DIR/Nordic" ]; then
    echo "==> Installing Nordic GTK theme..."
    cd /tmp
    wget -q https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
    tar -xf Nordic.tar.xz -C "$THEMES_DIR"
    rm Nordic.tar.xz
else
    echo "==> Nordic theme already installed"
fi

# Install Nordic-darker variant
if [ ! -d "$THEMES_DIR/Nordic-darker" ]; then
    echo "==> Installing Nordic-darker GTK theme..."
    cd /tmp
    wget -q https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz
    tar -xf Nordic-darker.tar.xz -C "$THEMES_DIR"
    rm Nordic-darker.tar.xz
else
    echo "==> Nordic-darker theme already installed"
fi

# Install Papirus icon theme (via package manager if available)
echo "==> Installing Papirus icon theme..."
if command -v apt &> /dev/null; then
    sudo apt install -y papirus-icon-theme 2>/dev/null || true
elif command -v dnf &> /dev/null; then
    sudo dnf install -y papirus-icon-theme 2>/dev/null || true
elif command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm papirus-icon-theme 2>/dev/null || true
fi

# Install Catppuccin GTK theme (optional - popular modern theme)
if [ ! -d "$THEMES_DIR/Catppuccin-Mocha-Standard-Mauve-Dark" ]; then
    echo "==> Installing Catppuccin Mocha GTK theme..."
    cd /tmp
    wget -q https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-mauve-standard+default.zip -O catppuccin.zip
    unzip -q catppuccin.zip -d "$THEMES_DIR" 2>/dev/null || true
    rm -f catppuccin.zip
fi

echo "==> Theme installation complete!"
echo ""
echo "To apply themes, use GNOME Tweaks or run:"
echo "  gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'"
echo "  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
