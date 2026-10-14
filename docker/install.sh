#!/usr/bin/env bash
#
# Docker WITHOUT Docker Desktop.
#
# Docker Desktop requires a paid subscription for companies of our size, so we
# do not install or use it. Instead (all from Homebrew, all open source):
#
#   docker          the Docker CLI
#   colima          the Linux VM that actually runs containers (the daemon)
#   docker-compose  `docker compose`, installed as a CLI plugin
#   docker-buildx   `docker buildx` / BuildKit builds, installed as a CLI plugin
#   lazydocker      terminal UI for containers, images and logs
#
# Safe to re-run.

set -euo pipefail

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

command -v brew >/dev/null 2>&1 || { echo "Please install Homebrew first. See: homebrew/install.sh" >&2; exit 1; }

# --- Refuse to quietly coexist with Docker Desktop ---------------------------
if [[ -d /Applications/Docker.app ]] || brew list --cask docker >/dev/null 2>&1; then
  warn "Docker Desktop is installed. Using it at our size violates Docker's license terms."
  warn "Quit it and remove it:  brew uninstall --cask docker   (or drag Docker.app to the Trash)"
fi

# --- Install -----------------------------------------------------------------
say "Installing docker, colima, docker-compose, docker-buildx, lazydocker..."
brew install docker colima docker-compose docker-buildx lazydocker

# --- Register compose and buildx as Docker CLI plugins -----------------------
# The Docker CLI finds plugins in ~/.docker/cli-plugins. Symlink to Homebrew's
# stable opt/ path so `brew upgrade` keeps working. (Homebrew's own caveat does
# the same thing by adding a "cliPluginsExtraDirs" entry to ~/.docker/config.json.)
PLUGIN_DIR="$HOME/.docker/cli-plugins"
mkdir -p "$PLUGIN_DIR"
for plugin in docker-compose docker-buildx; do
  ln -sfn "$(brew --prefix)/opt/$plugin/bin/$plugin" "$PLUGIN_DIR/$plugin"
done

# --- Leftovers from Docker Desktop -------------------------------------------
# Docker Desktop sets this; the helper it points at no longer exists, so every
# `docker pull` fails with "docker-credential-desktop: executable file not found".
if grep -qs '"credsStore"[[:space:]]*:[[:space:]]*"desktop"' "$HOME/.docker/config.json"; then
  warn '~/.docker/config.json still has "credsStore": "desktop" from Docker Desktop.'
  warn 'Delete that line (or change it to "osxkeychain" after: brew install docker-credential-helper).'
fi

echo
echo "Docker is installed. There is no daemon until you start Colima:"
echo "  colima start                      # first run creates the VM"
echo "  brew services start colima        # optional: start it at login"
echo "Apple Silicon, to run amd64 images faster: colima start --vm-type vz --vz-rosetta"
echo "Then: docker run hello-world, docker compose version, lazydocker"
