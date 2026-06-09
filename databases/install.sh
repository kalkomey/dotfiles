#!/usr/bin/env zsh
#
# Databases (see docs/package-matrix.md). macOS: force-link the Homebrew mysql/
# postgresql for their headers. Ubuntu: apt packages (mysql/postgresql/redis/
# memcached) under systemd. In practice apps run these via Docker Compose; this
# is for local tooling/clients. Independently runnable, safe to re-run.

set -e

OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
  brew_command="$(which brew)"
  echo "Force linking mysql and postgresql for their respective headers"
  ${brew_command} link --force --overwrite mysql@5.7 || true
  ${brew_command} link --force --overwrite postgresql || true

elif [[ "$OS" == "Linux" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  sudo apt-get install -y -qq mysql-server postgresql redis-server memcached
  echo "Installed mysql/postgresql/redis/memcached via apt (systemd-managed)."

else
  echo "databases/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi
