#!/usr/bin/env zsh
#
# Ruby via ruby-install + chruby (see docs/package-matrix.md). Installs a modern
# default; repos pin their own version via .ruby-version. Independently runnable.
#
# NOTE: the default below is a baseline — confirm against the team's apps before
# merging. Older 2.x apps that need openssl@1.1 install their Ruby per-repo.

RUBIES_TO_INSTALL=(3.3.6)
DEFAULT_RUBY_VERSION=${RUBIES_TO_INSTALL[1]}
mkdir -p "$HOME/.rubies"

OS="$(uname)"

# Build flags. macOS: point at Homebrew openssl@3. Ubuntu: rely on the apt -dev
# packages installed by script/packages/ubuntu.sh (libssl-dev, libyaml-dev, …) —
# no Homebrew paths. (Ruby 3.1+ builds cleanly against OpenSSL 3.)
if [[ "$OS" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  if [ -d "${brew_prefix}/opt/openssl@3" ]; then
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${brew_prefix}/opt/openssl@3"
  fi
fi

echo "Installing rubies"
for ruby_ver in ${RUBIES_TO_INSTALL[*]}; do
  if [ -d "$HOME/.rubies/ruby-${ruby_ver}" ]; then
    echo "ruby-${ruby_ver} already installed"
  else
    echo "Installing: ruby-${ruby_ver}"
    ruby-install --no-reinstall ruby "${ruby_ver}"
  fi
done

echo "Setting default ruby to ${DEFAULT_RUBY_VERSION}"
echo "${DEFAULT_RUBY_VERSION}" > "$HOME/.ruby-version"
