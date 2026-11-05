#!/usr/bin/env bash
#
# Applications: install the chosen desktop apps from Homebrew casks.
# Reads the answers saved by script/ask (and runs it first if there are none).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

if [[ -z "$APPS" ]]; then
  say "No applications selected; skipping."
  exit 0
fi

# --adopt takes over an app that is already in /Applications (installed by hand
# or from a download) instead of failing with "already an App at ...".
# shellcheck disable=SC2086  # $APPS is a space-separated list of cask names
BREW_INSTALL_FLAGS="--adopt" brew_install_missing --cask $APPS || warn "Some applications failed to install."
