#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_status "Starting dotfiles setup..."

# Define source paths
CONFIG_DIR=~/repos/config
TARGET_ZSHRC=$CONFIG_DIR/.zshrc
GHOSTTY_CONFIG_SOURCE=$CONFIG_DIR/ghostty-config
ZED_CONFIG_SOURCE=$CONFIG_DIR/zed-config.json
GITIGNORE_SOURCE=$CONFIG_DIR/.gitignore_global

# Verify config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    print_error "Config directory not found at $CONFIG_DIR"
    exit 1
fi

print_status "Setting up Zsh configuration..."
if [ -f "$TARGET_ZSHRC" ]; then
    ln -sf "$TARGET_ZSHRC" ~/.zshrc
    print_success "Zsh config symlinked to ~/.zshrc"
else
    print_warning "Zsh config file not found at $TARGET_ZSHRC"
fi

print_status "Setting up global git configuration..."
if [ -f "$GITIGNORE_SOURCE" ]; then
    git config --global core.excludesfile "$GITIGNORE_SOURCE"
    print_success "Global gitignore configured"
else
    print_warning "Global gitignore file not found at $GITIGNORE_SOURCE"
fi

print_status "Checking for Ghostty installation..."
if command_exists ghostty; then
    print_success "Ghostty is installed"

    if [ -f "$GHOSTTY_CONFIG_SOURCE" ]; then
        GHOSTTY_CONFIG_DIR=~/.config/ghostty
        mkdir -p "$GHOSTTY_CONFIG_DIR"
        ln -sf "$GHOSTTY_CONFIG_SOURCE" "$GHOSTTY_CONFIG_DIR/config"
        print_success "Ghostty config symlinked to ~/.config/ghostty/config"
    else
        print_warning "Ghostty config file not found at $GHOSTTY_CONFIG_SOURCE"
    fi
else
    print_warning "Ghostty not installed - skipping Ghostty configuration"
    print_status "To install Ghostty: brew install ghostty"
fi

print_status "Checking for Zed installation..."
if command_exists zed || [ -d "/Applications/Zed.app" ]; then
    print_success "Zed is installed"

    if [ -f "$ZED_CONFIG_SOURCE" ]; then
        ZED_CONFIG_DIR=~/.config/zed
        mkdir -p "$ZED_CONFIG_DIR"
        ln -sf "$ZED_CONFIG_SOURCE" "$ZED_CONFIG_DIR/settings.json"
        print_success "Zed config symlinked to ~/.config/zed/settings.json"
    else
        print_warning "Zed config file not found at $ZED_CONFIG_SOURCE"
    fi
else
    print_warning "Zed not installed - skipping Zed configuration"
    print_status "To install Zed: brew install zed"
fi

print_status "Checking for required fonts..."
if fc-list 2>/dev/null | grep -i "fira code" >/dev/null || system_profiler SPFontsDataType 2>/dev/null | grep -i "fira code" >/dev/null; then
    print_success "Fira Code font is installed"
else
    print_warning "Fira Code font not found"
    print_status "To install Fira Code: brew install --cask font-fira-code"
fi

if fc-list 2>/dev/null | grep -i "meslolgs nf" >/dev/null || system_profiler SPFontsDataType 2>/dev/null | grep -i "meslolgs nf" >/dev/null; then
    print_success "MesloLGS NF font is installed"
else
    print_warning "MesloLGS NF font not found"
    print_status "To install MesloLGS NF: brew install --cask font-meslo-lg-nerd-font"
fi

echo ""
print_success "Dotfiles setup completed!"
print_status "Summary of configured applications:"
echo "  ✓ Zsh configuration"
echo "  ✓ Git global settings"
if command_exists ghostty; then
    echo "  ✓ Ghostty terminal"
else
    echo "  - Ghostty terminal (not installed)"
fi
if command_exists zed || [ -d "/Applications/Zed.app" ]; then
    echo "  ✓ Zed editor"
else
    echo "  - Zed editor (not installed)"
fi

echo ""
print_status "You may need to restart your terminal or applications to see changes."
