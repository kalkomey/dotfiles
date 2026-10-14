#!/usr/bin/env bash
#
# Neovim + LazyVim (opt-in). Reads the answers saved by script/ask.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

if [[ "$NEOVIM" != 1 ]]; then
  say "Neovim not selected; skipping."
  exit 0
fi

say "Installing neovim, fd and lazygit..."
mise use --global --yes neovim fd lazygit

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [[ -e "$NVIM_DIR" ]]; then
  say "$NVIM_DIR already exists; leaving your Neovim config alone."
else
  say "Installing LazyVim starter into $NVIM_DIR..."
  git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_DIR"
  rm -rf "$NVIM_DIR/.git"   # your config, not a checkout of the starter
  say "Installing LazyVim plugins (first run)..."
  # `mise exec` puts the mise-installed nvim on PATH (mise activate only runs in interactive shells).
  mise exec -- nvim --headless "+Lazy! sync" +qa || warn "Plugin sync failed; it will retry when you first open nvim."
fi
