#!/usr/bin/env bash
#
# Nerd Fonts: install the chosen font casks from Homebrew.
# Reads the answers saved by script/ask (and runs it first if there are none).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

if [[ -z "$FONTS" ]]; then
  say "No Nerd Fonts selected; skipping."
  exit 0
fi

casks=()
for f in $FONTS; do casks+=("font-$f-nerd-font"); done
say "Installing Nerd Fonts: $FONTS"
brew install --cask "${casks[@]}" || warn "Some fonts failed to install."
echo "  Set your terminal font to the family name, e.g. 'FiraCode Nerd Font' (see Font Book)."
echo "  Ligatures: enable in iTerm2 (Profiles > Text > Use ligatures); Terminal.app has no ligature support."
