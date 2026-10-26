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

. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"

load_brew || die "Homebrew is not installed. Run script/ask (it installs Homebrew), or bin/dot."

# --- Refuse to quietly coexist with Docker Desktop ---------------------------
if [[ -d /Applications/Docker.app ]] || brew list --cask docker >/dev/null 2>&1; then
  warn "Docker Desktop is installed. Using it at our size violates Docker's license terms."
  warn "Quit it and remove it:  brew uninstall --cask docker   (or drag Docker.app to the Trash)"
fi

# --- Install -----------------------------------------------------------------
brew_install_missing docker colima docker-compose docker-buildx lazydocker

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

# --- Start Colima now, and at every login ------------------------------------
# `brew services` registers a launchd agent that runs `colima start -f` when you log
# in, so Colima is back after a reboot as soon as you sign in. It cannot take flags;
# the VM uses whatever settings Colima has saved for its profile (~/.colima/default).
if brew services list 2>/dev/null | awk '$1 == "colima" && $2 == "started" { f = 1 } END { exit !f }'; then
  say "Colima is already set to start at login."
  # `started` only means the launchd job is alive, not that the VM is. If the VM
  # has died, the job lingers in the foreground and nothing restarts it, so docker
  # reports "no such file" for the socket until someone runs `colima start`.
  if ! colima status >/dev/null 2>&1; then
    quiet_run "Colima's VM is not running, starting it..." colima start \
      || warn "Could not start Colima. Try it yourself: colima start"
  fi
elif colima status >/dev/null 2>&1; then
  # Started by hand. Starting the service now would fight with it, and stopping it
  # would stop your running containers, so leave that choice to the engineer.
  say "Colima is already running (started by hand). To also start it at login:"
  echo "  colima stop && brew services start colima"
else
  quiet_run "Starting Colima now and at every login (brew services)..." brew services start colima \
    || warn "Could not register the Colima service. Start it yourself: colima start"
fi

echo
echo "Docker is installed. The first start creates the VM and downloads an image, so give it a minute."
echo "  colima status                     # is it running?"
echo "  docker run --rm hello-world       # try it once it is"
echo "  docker compose version, lazydocker"
echo "Apple Silicon, to run amd64 images faster, turn on Rosetta: colima stop && colima start --vz-rosetta"
