#!/bin/bash

# -----------------------------
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()   { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success()  { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning()  { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()    { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

print_status "Starting dotfiles setup..."

# -----------------------------
# Paths
CONFIG_DIR=~/repos/config
TARGET_ZSHRC=$CONFIG_DIR/.zshrc
GHOSTTY_CONFIG_SOURCE=$CONFIG_DIR/ghostty-config
ZED_CONFIG_SOURCE=$CONFIG_DIR/zed-config.json
GITIGNORE_SOURCE=$CONFIG_DIR/.gitignore_global

# -----------------------------
# Verify config directory
if [ ! -d "$CONFIG_DIR" ]; then
    print_error "Config directory not found at $CONFIG_DIR"
    exit 1
fi

# -----------------------------
# Symlink Zsh config
print_status "Setting up Zsh configuration..."
if [ -f "$TARGET_ZSHRC" ]; then
    ln -sf "$TARGET_ZSHRC" ~/.zshrc
    print_success "Zsh config symlinked to ~/.zshrc"
else
    print_warning "Zsh config file not found at $TARGET_ZSHRC"
fi

# -----------------------------
# Check required Homebrew packages (but don't mess with Oh My Zsh)
print_status "Checking required Homebrew packages..."
for pkg in zsh-autosuggestions zsh-syntax-highlighting powerlevel10k; do
    if brew list "$pkg" >/dev/null 2>&1; then
        print_success "$pkg is installed"
    else
        print_warning "$pkg not installed"
        print_status "To install: brew install $pkg"
    fi
done

# -----------------------------
# Git config
print_status "Setting up global git configuration..."
if [ -f "$GITIGNORE_SOURCE" ]; then
    git config --global core.excludesfile "$GITIGNORE_SOURCE"
    print_success "Global gitignore configured"
else
    print_warning "Global gitignore file not found at $GITIGNORE_SOURCE"
fi

# -----------------------------
# Ghostty
print_status "Checking for Ghostty installation..."
if command_exists ghostty || [ -d "/Applications/Ghostty.app" ] || [ -d "$HOME/Applications/Ghostty.app" ]; then
    print_success "Ghostty is installed"
    if [ -f "$GHOSTTY_CONFIG_SOURCE" ]; then
        GHOSTTY_CONFIG_DIR=~/.config/ghostty
        mkdir -p "$GHOSTTY_CONFIG_DIR"
        ln -sf "$GHOSTTY_CONFIG_SOURCE" "$GHOSTTY_CONFIG_DIR/config"
        print_success "Ghostty config symlinked"
    else
        print_warning "Ghostty config file not found at $GHOSTTY_CONFIG_SOURCE"
    fi
else
    print_warning "Ghostty not installed - skipping"
    print_status "To install Ghostty: brew install --cask ghostty"
fi

# -----------------------------
# Zed
print_status "Checking for Zed installation..."
if command_exists zed || [ -d "/Applications/Zed.app" ]; then
    print_success "Zed is installed"
    if [ -f "$ZED_CONFIG_SOURCE" ]; then
        ZED_CONFIG_DIR=~/.config/zed
        mkdir -p "$ZED_CONFIG_DIR"
        ln -sf "$ZED_CONFIG_SOURCE" "$ZED_CONFIG_DIR/settings.json"
        print_success "Zed config symlinked"
    else
        print_warning "Zed config file not found at $ZED_CONFIG_SOURCE"
    fi
else
    print_warning "Zed not installed - skipping"
    print_status "To install Zed: brew install zed"
fi

# -----------------------------
# Neovim (kickstart.nvim)
print_status "Checking for Neovim installation..."
if command_exists nvim; then
    print_success "Neovim is installed"

    NVIM_CONFIG_DIR=~/.config/nvim
    KICKSTART_REPO="https://github.com/nvim-lua/kickstart.nvim.git"

    if [ -d "$NVIM_CONFIG_DIR" ]; then
        print_warning "Neovim config already exists at $NVIM_CONFIG_DIR"
        print_status "To install kickstart.nvim, backup and remove the existing config:"
        print_status "  mv ~/.config/nvim ~/.config/nvim.backup"
        print_status "  git clone $KICKSTART_REPO $NVIM_CONFIG_DIR"
    else
        print_status "Installing kickstart.nvim..."
        if git clone "$KICKSTART_REPO" "$NVIM_CONFIG_DIR" 2>/dev/null; then
            print_success "kickstart.nvim installed successfully"
            print_status "Run 'nvim' to install plugins automatically"
        else
            print_error "Failed to clone kickstart.nvim"
            print_status "Manual installation: git clone $KICKSTART_REPO $NVIM_CONFIG_DIR"
        fi
    fi
else
    print_warning "Neovim not installed - skipping"
    print_status "To install Neovim: brew install neovim"
fi

# -----------------------------
# Fonts
print_status "Checking for required fonts..."
if system_profiler SPFontsDataType 2>/dev/null | grep -qi "Fira Code"; then
    print_success "Fira Code font is installed"
else
    print_warning "Fira Code font not found"
    print_status "To install: brew install --cask font-fira-code"
fi

if system_profiler SPFontsDataType 2>/dev/null | grep -qi "Meslo.*Nerd"; then
    print_success "Meslo Nerd Font is installed"
else
    print_warning "Meslo Nerd Font not found"
    print_status "To install: brew install --cask font-meslo-lg-nerd-font"
fi

# -----------------------------
# K9s plugins
print_status "Setting up K9s plugins..."
if command_exists k9s; then
    print_success "K9s is installed"

    PLUGINS_DIR="$HOME/Library/Application Support/k9s/plugins"
    mkdir -p "$PLUGINS_DIR"

    # Copy plugins from local k9s-plugins directory
    PLUGINS_SOURCE="$CONFIG_DIR/k9s-plugins"

    if [ -d "$PLUGINS_SOURCE" ]; then
        print_status "Copying plugins from $PLUGINS_SOURCE"

        for plugin_file in "$PLUGINS_SOURCE"/*.yaml; do
            if [ -f "$plugin_file" ]; then
                plugin_name=$(basename "$plugin_file")
                print_status "Installing plugin: $plugin_name"
                if cp "$plugin_file" "$PLUGINS_DIR/$plugin_name"; then
                    print_success "✓ $plugin_name"
                else
                    print_warning "✗ Failed to copy $plugin_name"
                fi
            fi
        done
    else
        print_warning "Plugins directory not found at $PLUGINS_SOURCE"
    fi

else
    print_warning "K9s not installed - skipping plugins"
    print_status "To install K9s: brew install k9s"
fi

# -----------------------------
#d!"
print_status "Summary:"
echo "  ✓ Zsh configuration"
echo "  ✓ Git global settings"
if command_exists ghostty || [ -d "/Applications/Ghostty.app" ] || [ -d "$HOME/Applications/Ghostty.app" ]; then
    echo "  ✓ Ghostty terminal"
else
    echo "  - Ghostty terminal (not installed)"
fi
if command_exists zed || [ -d "/Applications/Zed.app" ]; then
    echo "  ✓ Zed editor"
else
    echo "  - Zed editor (not installed)"
fi
if command_exists nvim; then
    echo "  ✓ Neovim"
else
    echo "  - Neovim (not installed)"
fi

echo ""
print_status "Next steps:"
echo "  1. Install any missing Homebrew packages shown above"
echo "  2. Restart your terminal or run: source ~/.zshrc"
