#!/bin/bash
# =============================================================================
# Enhanced Zsh Installation Script for Linux Mint
# =============================================================================

set -e  # Exit on error

echo "🚀 Installing Enhanced Zsh Configuration for Linux Mint..."
echo "=================================================="

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install essential packages
echo "📦 Installing essential packages..."
sudo apt install -y \
    zsh \
    git \
    curl \
    jq \
    fzf \
    ripgrep \
    bat \
    fd-find \
    trash-cli \
    xclip \
    neovim \
    python3-pip \
    p7zip-full

# Install optional but recommended packages (continue on error)
echo "📦 Installing optional packages..."
sudo apt install -y eza btop zoxide direnv 2>/dev/null || true

# Backup existing .zshrc if it exists
if [[ -f ~/.zshrc ]]; then
    echo "💾 Backing up existing .zshrc..."
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# Download the enhanced .zshrc
echo "📥 Downloading Enhanced Zsh Configuration..."
curl -fsSL https://raw.githubusercontent.com/yourusername/zshrc/main/.zshrc -o ~/.zshrc

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p ~/.cache/zsh ~/.local/state/zsh ~/.local/bin

# Install Zinit (plugin manager)
echo "🔌 Installing Zinit plugin manager..."
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Create secrets template
echo "🔐 Creating secrets template..."
cat > ~/.secrets.zsh.template << 'EOF'
# ~/.secrets.zsh - Store your API keys and secrets here
# This file should NOT be committed to version control

# AI API Keys
export PERPLEXITY_API_KEY='your-perplexity-api-key-here'

# Other secrets
# export GITHUB_TOKEN='your-github-token-here'
EOF

if [[ ! -f ~/.secrets.zsh ]]; then
    cp ~/.secrets.zsh.template ~/.secrets.zsh
    chmod 600 ~/.secrets.zsh
    echo "   Created ~/.secrets.zsh - Add your API keys there!"
fi

# Fix fd command name on Debian/Ubuntu
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    echo "🔧 Creating fd symlink..."
    ln -s $(which fdfind) ~/.local/bin/fd 2>/dev/null || true
fi

# Set Zsh as default shell
echo "🐚 Setting Zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
    echo "   ✓ Default shell changed to Zsh"
else
    echo "   ✓ Zsh is already your default shell"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (or run: exec zsh)"
echo "2. Run: p10k configure (to customize your prompt)"
echo "3. Add your API keys to ~/.secrets.zsh"
echo ""
echo "Useful commands to try:"
echo "- ff         : Find files with preview"
echo "- pj         : Jump to projects"
echo "- px 'hello' : Test AI assistant"
echo "- zsh-time   : Check startup performance"
echo ""
echo "Enjoy your new Enhanced Zsh! 🎉"
