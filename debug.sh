#!/bin/bash

# Debug and fix Oh My Zsh plugins setup
echo "🔍 Debugging Oh My Zsh plugin setup..."

# Check Homebrew installations
echo -e "\n📦 Checking Homebrew installations:"
for pkg in zsh-autosuggestions zsh-syntax-highlighting powerlevel10k; do
    if brew list "$pkg" >/dev/null 2>&1; then
        echo "  ✅ $pkg installed"
        echo "     Location: $(brew --prefix $pkg)"
    else
        echo "  ❌ $pkg NOT installed"
        echo "     Run: brew install $pkg"
    fi
done

# Check Oh My Zsh custom directory
echo -e "\n📁 Oh My Zsh custom directory:"
OHMYZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
echo "  Custom dir: $OHMYZSH_CUSTOM"
mkdir -p "$OHMYZSH_CUSTOM/plugins" "$OHMYZSH_CUSTOM/themes"

echo -e "\n🔗 Current symlinks in plugins directory:"
ls -la "$OHMYZSH_CUSTOM/plugins/"

echo -e "\n🔗 Current symlinks in themes directory:"
ls -la "$OHMYZSH_CUSTOM/themes/"

# Fix the symlinks
echo -e "\n🛠️  Creating/fixing symlinks..."

# Remove any broken symlinks first
find "$OHMYZSH_CUSTOM/plugins/" -type l ! -exec test -e {} \; -exec rm {} \; 2>/dev/null
find "$OHMYZSH_CUSTOM/themes/" -type l ! -exec test -e {} \; -exec rm {} \; 2>/dev/null

# Create correct symlinks
if brew list zsh-autosuggestions >/dev/null 2>&1; then
    ln -sfn "$(brew --prefix zsh-autosuggestions)/share/zsh-autosuggestions" "$OHMYZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "  ✅ zsh-autosuggestions symlink created"
fi

if brew list zsh-syntax-highlighting >/dev/null 2>&1; then
    ln -sfn "$(brew --prefix zsh-syntax-highlighting)/share/zsh-syntax-highlighting" "$OHMYZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "  ✅ zsh-syntax-highlighting symlink created"
fi

if brew list powerlevel10k >/dev/null 2>&1; then
    ln -sfn "$(brew --prefix powerlevel10k)/share/powerlevel10k" "$OHMYZSH_CUSTOM/themes/powerlevel10k"
    echo "  ✅ powerlevel10k symlink created"
fi

# Verify the symlinks work
echo -e "\n✅ Verifying symlinks:"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ -d "$OHMYZSH_CUSTOM/plugins/$plugin" ]; then
        echo "  ✅ $plugin directory exists and accessible"
        # Check for the main plugin file
        if [ -f "$OHMYZSH_CUSTOM/plugins/$plugin/$plugin.zsh" ]; then
            echo "     📄 Main plugin file found"
        else
            echo "     ❌ Main plugin file NOT found"
            echo "     Contents:"
            ls -la "$OHMYZSH_CUSTOM/plugins/$plugin/" | head -5
        fi
    else
        echo "  ❌ $plugin directory NOT accessible"
    fi
done

if [ -d "$OHMYZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "  ✅ powerlevel10k theme directory exists and accessible"
else
    echo "  ❌ powerlevel10k theme directory NOT accessible"
fi

echo -e "\n🎯 Next steps:"
echo "  1. If any packages are missing, install them with: brew install <package-name>"
echo "  2. If symlinks look good, restart your terminal or run: source ~/.zshrc"
echo "  3. If still having issues, the plugin files might be in a different location within the Homebrew installation"
