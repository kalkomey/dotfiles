#!/usr/bin/env zsh
#
# Node via nvm (see docs/package-matrix.md). Installs a current LTS default; repos
# pin their own version via .nvmrc. Independently runnable.
#
# NOTE: the default below is a baseline — confirm against the team's apps before
# merging. Older apps install their Node per-repo via nvm + .nvmrc.

export NVM_DIR="$HOME/.nvm"

# Load nvm from wherever it lives. macOS gets nvm from the Brewfile; on Linux,
# install it (the official installer) if it's missing.
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  . "/opt/homebrew/opt/nvm/nvm.sh"
elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
  . "/usr/local/opt/nvm/nvm.sh"
elif [[ "$(uname)" == "Linux" ]]; then
  echo "Installing nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  . "$NVM_DIR/nvm.sh"
fi

NODES_TO_INSTALL=(22)
DEFAULT_NODE_VERSION=${NODES_TO_INSTALL[1]}

echo "Installing nodes"
for node_ver in ${NODES_TO_INSTALL[*]}; do
  echo "Installing: node ${node_ver} (latest ${node_ver}.x)"
  nvm install "${node_ver}"
done

echo "Setting default node to ${DEFAULT_NODE_VERSION}"
nvm alias default "${DEFAULT_NODE_VERSION}"
echo "${DEFAULT_NODE_VERSION}" > "$HOME/.node-version"
