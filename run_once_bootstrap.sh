#!/bin/bash
# Bootstrap script for setting up a new machine with chezmoi
# This script runs once when chezmoi apply is executed

set -e

echo "=== Starting Bootstrap Setup ==="

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf check-update || true"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    UPDATE_CMD="sudo pacman -Sy"
fi

echo "Detected package manager: $PKG_MANAGER"

# Update package lists
echo "=== Updating package lists ==="
$UPDATE_CMD

# Install core packages
echo "=== Installing core packages ==="
PACKAGES="zsh tmux git curl wget neovim kitty bat btop neofetch ranger fzf ripgrep"

for pkg in $PACKAGES; do
    if ! command -v $pkg &> /dev/null; then
        echo "Installing $pkg..."
        $INSTALL_CMD $pkg || echo "Failed to install $pkg, continuing..."
    else
        echo "$pkg already installed"
    fi
done

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "=== Installing Oh My Zsh ==="
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "=== Installing Powerlevel10k theme ==="
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "=== Installing zsh-autosuggestions ==="
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "=== Installing zsh-syntax-highlighting ==="
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Refresh font cache
echo "=== Refreshing font cache ==="
if command -v fc-cache &> /dev/null; then
    fc-cache -fv
fi

# Install VSCode extensions
if command -v code &> /dev/null && [ -f "$HOME/.config/Code/extensions.txt" ]; then
    echo "=== Installing VSCode extensions ==="
    while IFS= read -r extension; do
        code --install-extension "$extension" || echo "Failed to install $extension"
    done < "$HOME/.config/Code/extensions.txt"
fi

# Apply dconf settings (GNOME)
if command -v dconf &> /dev/null && [ -f "$HOME/.config/dconf-backup.txt" ]; then
    echo "=== Applying dconf/GNOME settings ==="
    dconf load / < "$HOME/.config/dconf-backup.txt"
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "=== Setting zsh as default shell ==="
    chsh -s $(which zsh) || echo "Run 'chsh -s \$(which zsh)' manually to change shell"
fi

# Install Homebrew (for additional tools like chezmoi, eza, etc.)
if ! command -v brew &> /dev/null; then
    echo "=== Installing Homebrew ==="
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for this session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install brew packages
if command -v brew &> /dev/null; then
    echo "=== Installing Homebrew packages ==="
    BREW_PACKAGES="eza fd lazygit"
    for pkg in $BREW_PACKAGES; do
        brew install $pkg || echo "Failed to install $pkg via brew"
    done
fi

echo "=== Bootstrap complete! ==="
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
echo "You may need to log out and back in for the default shell change to take effect."
