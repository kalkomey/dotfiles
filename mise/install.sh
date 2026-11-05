#!/usr/bin/env bash
#
# mise: install the chosen languages and CLI tools globally.
# Reads the answers saved by script/ask (and runs it first if there are none).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

# Libraries needed when a language (mostly Ruby) has to compile from source.
BUILD_DEPS=(openssl@3 libyaml readline libffi gdbm zlib autoconf automake pkgconf)

if [[ -z "${SKIP_BREW_DEPS:-}" ]]; then
  brew_install_missing "${BUILD_DEPS[@]}"
fi

# People who already use mise have a global config. `mise use --global` edits it in
# place (it changes the entry for each tool we install and leaves the rest), so keep
# a copy first. If it is a symlink (stow), mise writes through into that repo.
MISE_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
for f in config.toml settings.toml; do
  [[ -e "$MISE_CONF_DIR/$f" ]] || continue
  bk="$HOME/.dotfiles-backup/mise-$f.$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$(dirname "$bk")"
  cp -p "$MISE_CONF_DIR/$f" "$bk"
  say "Existing mise $f backed up to $bk; entries for the tools you chose are updated in place."
  if [[ -L "$MISE_CONF_DIR/$f" ]]; then
    warn "$MISE_CONF_DIR/$f is a symlink to $(readlink "$MISE_CONF_DIR/$f"); mise will edit that file."
  fi
done

# Honor legacy .ruby-version / .node-version files so existing
# repos work without a .tool-versions migration.
say "Configuring mise..."
mise settings add idiomatic_version_file_enable_tools ruby >/dev/null
mise settings add idiomatic_version_file_enable_tools node >/dev/null

say "Installing languages: $MISE_LANGUAGES"
# shellcheck disable=SC2086
mise use --global --yes $MISE_LANGUAGES

say "Installing tools: $MISE_TOOLS"
# shellcheck disable=SC2086
mise use --global --yes $MISE_TOOLS

say "Installed versions:"
mise ls --current
