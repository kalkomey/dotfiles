#!/usr/bin/env zsh
#
# Python via pyenv (see docs/package-matrix.md). Mirrors ruby/install.sh: a
# managed runtime, pinned per-repo via .python-version. Independently runnable
# and safe to re-run — installs its own prerequisites on Linux.

set -e

PYTHONS_TO_INSTALL=(3.12.8)
DEFAULT_PYTHON_VERSION=${PYTHONS_TO_INSTALL[1]}

OS="$(uname)"

# 1. Ensure pyenv (and the system prerequisites it needs to build CPython).
if [[ "$OS" == "Darwin" ]]; then
  if ! command -v pyenv >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      brew install pyenv pipx
    else
      echo "pyenv not found and Homebrew is missing; run homebrew/install.sh first" >&2
      exit 1
    fi
  fi
elif [[ "$OS" == "Linux" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  # pyenv's documented CPython build dependencies, plus pipx for python CLI tools.
  sudo apt-get install -y -qq \
    make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev pipx
  if [[ ! -d "$HOME/.pyenv" ]]; then
    curl -fsSL https://pyenv.run | bash
  fi
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
else
  echo "python/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi

eval "$(pyenv init -)"

# 2. Install the pinned Python(s).
for py in ${PYTHONS_TO_INSTALL[*]}; do
  echo "Installing python ${py} (skipped if already present)"
  pyenv install --skip-existing "$py"
done

# 3. Set the global default and write ~/.python-version.
echo "Setting default python to ${DEFAULT_PYTHON_VERSION}"
pyenv global "$DEFAULT_PYTHON_VERSION"
echo "$DEFAULT_PYTHON_VERSION" > "$HOME/.python-version"

# 4. Make pipx-installed tools (pre-commit, ansible — see infra/install.sh) reachable.
if command -v pipx >/dev/null 2>&1; then
  pipx ensurepath >/dev/null 2>&1 || true
fi
