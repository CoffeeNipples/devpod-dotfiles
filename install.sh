#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORKSPACE_DIR="$(find /workspaces -mindepth 1 -maxdepth 1 -type d | head -n 1)"
export CODEX_HOME="$WORKSPACE_DIR/.codex-state"

if [ -z "$WORKSPACE_DIR" ]; then
    echo "ERROR: Could not determine workspace directory"
    exit 1
fi

echo "==> Setting up development environment"

# Persist CODEX_HOME for future shell sessions
grep -q '^export CODEX_HOME=' "$HOME/.bashrc" 2>/dev/null || \
    echo "export CODEX_HOME=\"$CODEX_HOME\"" >> "$HOME/.bashrc"

# Convert Debian repositories from HTTP -> HTTPS
sudo sed -i 's|http://deb.debian.org|https://deb.debian.org|g' \
    /etc/apt/sources.list /etc/apt/sources.list.d/*.sources 2>/dev/null || true

# Refresh package indexes
sudo apt-get update

# Install Node/npm if missing
if ! command -v npm >/dev/null 2>&1; then
    sudo apt-get install -y nodejs npm
fi

# Install/update Codex
sudo npm install -g @openai/codex

# Install Neovim
sudo apt-get install -y neovim

# Create persistent Codex state directory
mkdir -p "$CODEX_HOME"

# Install baseline Codex config only if supplied by dotfiles
if [ -f "$DOTFILES_DIR/codex/config.toml" ] && \
   [ ! -f "$CODEX_HOME/config.toml" ]; then
    cp "$DOTFILES_DIR/codex/config.toml" "$CODEX_HOME/config.toml"
fi

echo "==> Dev environment ready"
