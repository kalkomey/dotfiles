#!/usr/bin/env zsh
#
# Docker (see docs/package-matrix.md). macOS: Docker Desktop (cask). Ubuntu:
# Docker Engine from Docker's official apt repo. Independently runnable, idempotent.

set -e

OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    brew install --cask docker
  else
    echo "docker/install.sh: Homebrew missing; run homebrew/install.sh first" >&2
    exit 1
  fi

elif [[ "$OS" == "Linux" ]]; then
  export DEBIAN_FRONTEND=noninteractive

  # Docker's official apt repo.
  sudo install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
  fi
  # shellcheck source=/dev/null  # system file, present only on the target host
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Run docker without sudo. Group membership takes effect on next login.
  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    sudo usermod -aG docker "$USER"
    echo "Added $USER to the 'docker' group — log out and back in for it to take effect."
  fi

else
  echo "docker/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi
