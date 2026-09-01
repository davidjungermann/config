# macOS Development Environment Setup

Automated configuration for quickly setting up a macOS development machine with consistent dotfiles, applications, and settings.

## 🚀 Quick Start

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url> ~/repos/config
   cd ~/repos/config
   ```

2. **Install applications with Homebrew** (recommended first):
   ```bash
   brew bundle --file=Brewfile
   ```

3. **Run the setup script**:
   ```bash
   chmod +x script.sh
   ./script.sh
   ```

## 📦 Brew-First Installation

This setup is designed with a **Homebrew-first approach**. The Brewfile includes everything you need:

- **Applications**: `ghostty`, `zed`
- **Fonts**: `font-fira-code`, `font-meslo-lg-nerd-font`
- **Development tools**: All your CLI tools and utilities

**Recommended workflow for new machines:**
```bash
# 1. Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone and setup
git clone <your-repo-url> ~/repos/config
cd ~/repos/config

# 3. Install everything via Homebrew
brew bundle --file=Brewfile

# 4. Configure dotfiles
./script.sh
```

## 📁 What's Included

### Core Configuration Files

- **`.zshrc`** - Zsh shell configuration and customizations
- **`.gitignore_global`** - Global Git ignore patterns
- **`ghostty-config`** - Ghostty terminal emulator settings
- **`zed-config.json`** - Zed editor configuration
- **`Brewfile`** - Homebrew package and application definitions
- **Neovim** - [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) configuration automatically installed

### Setup Scripts

- **`script.sh`** - Main automated setup script with validation
- Installs and configures all dotfiles with proper symlinking
- Validates installed applications before configuration
- Provides colored output and helpful installation suggestions

## 🔧 Applications Configured

### Terminal: Ghostty
- **Theme**: Gruvbox Light/Dark (auto-switching)
- **Font**: MesloLGS NF (Nerd Font for icons and ligatures)
- **Config Location**: `~/.config/ghostty/config`

### Editor: Zed
- **Theme**: Gruvbox Light/Dark (system-based switching)
- **Font**: Fira Code (with programming ligatures)
- **Features**: Copilot integration, Helm language server
- **Config Location**: `~/.config/zed/settings.json`

### Editor: Neovim
- **Configuration**: [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - A minimal, well-documented starting point
- **Features**: LSP support, Treesitter, Telescope fuzzy finder, and more
- **Config Location**: `~/.config/nvim`
- **Auto-setup**: The setup script automatically clones kickstart.nvim if no existing config is found
- **Plugin Manager**: lazy.nvim (plugins install automatically on first launch)

### Shell: Zsh
- Custom prompt and aliases
- **Config Location**: `~/.zshrc`

### Git
- Global gitignore patterns
- **Config Location**: Uses `~/.gitignore_global`

## 📋 Prerequisites

### Required Fonts
The setup script will check for these fonts and provide installation instructions:

```bash
# Fira Code (for Zed editor)
brew install --cask font-fira-code

# MesloLGS NF (for Ghostty terminal)
brew install --cask font-meslo-lg-nerd-font

# Neovim
brew install neovim
```

### Applications from Brewfile
Your Brewfile includes everything needed:

```bash
# Core applications
cask "ghostty"          # Terminal emulator
cask "zed"              # Code editor
brew "neovim"           # Terminal-based editor

# Required fonts
cask "font-fira-code"           # For Zed editor
cask "font-meslo-lg-nerd-font"  # For Ghostty terminal

# Plus all your development tools...
```

The setup script validates these are installed and configures them automatically.

## Kubernetes contexts

The setup installs `kubeconfig-split`, which keeps everyday and production
contexts in separate local kubeconfig files without committing cluster access
configuration to this repository.

On first setup, the script offers to classify every context in
`~/.kube/config` as dev, production, or skipped. You can also run it later:

```bash
kubeconfig-split
```

The generated files are `~/.kube/dev` and `~/.kube/production`. Existing
outputs are timestamped before replacement. Select one in the current shell
with:

```bash
kubeconfig dev
kubeconfig production
```

The split only organizes contexts and reduces accidental context selection. It
does not change permissions: GCP IAM continues to control what each user can do
in a cluster.

New shells default to the dev file once it exists. The combined source
kubeconfig is left unchanged, so contexts can be reclassified later.

## 🎨 Theme Configuration

Both Ghostty and Zed are configured with **Gruvbox** theme:
- **Light mode**: Gruvbox Light Soft
- **Dark mode**: Gruvbox Dark Soft
- **Auto-switching**: Based on system appearance

## 🔄 Making Changes

All configuration files in this repository are symlinked to their respective locations. This means:

1. **Edit files in this repo** - changes apply immediately
2. **Version controlled** - all changes are tracked in Git
3. **Portable** - entire setup can be replicated on new machines

### Example: Updating Zed Settings
```bash
# Edit the config file
vim ~/repos/config/zed-config.json

# Changes are immediately available in Zed (may need restart)
```

## 🛠 Troubleshooting

### Setup Script Issues
The setup script provides detailed output with colors:
- 🔵 **INFO**: General progress updates
- 🟢 **SUCCESS**: Successful operations
- 🟡 **WARNING**: Non-critical issues with suggestions
- 🔴 **ERROR**: Critical failures

### Re-running Setup
The script is idempotent - safe to run multiple times:
```bash
./script.sh
```

### Missing Applications
If applications aren't installed, the script will show helpful warnings:
```bash
[WARNING] Ghostty not installed - skipping Ghostty configuration
[INFO] To install Ghostty: brew install ghostty
```

Simply run `brew bundle` then re-run the setup script.

### Existing Neovim Configuration
If you already have a Neovim configuration, the script will detect it and provide instructions:
```bash
[WARNING] Neovim config already exists at ~/.config/nvim
[INFO] To install kickstart.nvim, backup and remove the existing config:
[INFO]   mv ~/.config/nvim ~/.config/nvim.backup
[INFO]   git clone https://github.com/nvim-lua/kickstart.nvim ~/.config/nvim
```

### Manual Configuration
If automatic setup fails, you can manually create symlinks:

```bash
# Zsh
ln -sf ~/repos/config/.zshrc ~/.zshrc

# Git
git config --global core.excludesfile ~/repos/config/.gitignore_global

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf ~/repos/config/ghostty-config ~/.config/ghostty/config

# Zed
mkdir -p ~/.config/zed
ln -sf ~/repos/config/zed-config.json ~/.config/zed/settings.json

# Neovim (kickstart.nvim)
git clone https://github.com/nvim-lua/kickstart.nvim ~/.config/nvim
```

## 📚 Additional Resources

- [Ghostty Documentation](https://ghostty.org/docs)
- [Zed Documentation](https://zed.dev/docs)
- [Neovim Documentation](https://neovim.io/doc/)
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [Gruvbox Theme](https://github.com/morhetz/gruvbox)
- [Fira Code Font](https://github.com/tonsky/FiraCode)
