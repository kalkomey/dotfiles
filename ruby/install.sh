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

# On Ubuntu, ruby-install and chruby aren't packaged — install them from source if
# missing (macOS gets them from the Brewfile). chruby installs to /usr/local/share,
# which zsh/zshrc.symlink already sources.
install_from_source() {
  local name=$1 ver=$2 tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/postmodern/${name}/releases/download/v${ver}/${name}-${ver}.tar.gz" \
    -o "${tmp}/${name}.tar.gz"
  tar -xzf "${tmp}/${name}.tar.gz" -C "$tmp"
  sudo make -C "${tmp}/${name}-${ver}" install
  rm -rf "$tmp"
}
if [[ "$OS" == "Linux" ]]; then
  command -v ruby-install >/dev/null 2>&1 || { echo "Installing ruby-install"; install_from_source ruby-install 0.9.3; }
  [ -f /usr/local/share/chruby/chruby.sh ] || { echo "Installing chruby"; install_from_source chruby 0.3.9; }
fi

if ! command -v ruby-install >/dev/null 2>&1; then
  echo "ruby/install.sh: ruby-install unavailable; cannot install Ruby" >&2
  exit 1
fi

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
