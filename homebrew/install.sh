#!/usr/bin/env bash
#
# Homebrew: install the packages in the Brewfile.
#
# Homebrew itself is installed by script/ask (it needs it to check your answers),
# so this does not install it again; it only finds it and runs `brew bundle`.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"

load_brew || die "Homebrew is not installed. Run script/ask (it installs Homebrew), or bin/dot."

brew bundle --file "$DOTFILES_ROOT/homebrew/Brewfile" install

touch "${HOME}/.tmux.conf.local"
