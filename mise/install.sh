#!/usr/bin/env bash
#
# mise: install the chosen languages and CLI tools globally.
# Reads the answers saved by script/ask (and runs it first if there are none).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

# Libraries needed when a language (mostly Ruby) has to compile from source.
BUILD_DEPS=(openssl@3 libyaml readline libffi gdbm zlib autoconf automake pkg-config)

if [[ -z "${SKIP_BREW_DEPS:-}" ]]; then
  say "Installing build dependencies..."
  brew install "${BUILD_DEPS[@]}"
fi

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
