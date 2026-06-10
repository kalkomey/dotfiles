#!/usr/bin/env bash
#
# packages/ubuntu.sh
#
# Ubuntu-native package installation (see docs/package-matrix.md). Installs the
# base dev layer: apt build prerequisites and CLI tools, vendor apt repos for the
# "homeless" CLIs that have no topic installer (HashiCorp tools, GitHub CLI), and
# the official AWS CLI v2 binary (NOT apt — apt ships v1).
#
# Deliberately NOT here: Docker, MySQL/PostgreSQL/Redis/Memcached, Ruby, and Node.
# Those are owned by their topic installers (docker/, databases/, ruby/, node/),
# which branch per-OS and are run after this script by bin/dot.
#
# Idempotent and safe to re-run.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

ARCH="$(dpkg --print-architecture)"
# shellcheck source=/dev/null  # system file, present only on the target host
. /etc/os-release
CODENAME="${VERSION_CODENAME:-noble}"

log() { printf '\n==> %s\n' "$1"; }

install_apt_packages() {
  log "Updating apt and installing base packages"
  sudo apt-get update -qq

  # Build prerequisites (also needed later by ruby/install.sh).
  # CLI tools mirror the macOS Brewfile where an apt equivalent exists.
  sudo apt-get install -y -qq \
    build-essential gcc make autoconf bison pkg-config \
    libssl-dev libyaml-dev libffi-dev zlib1g-dev libreadline-dev libgdbm-dev \
    ca-certificates curl wget gnupg unzip \
    zsh git git-lfs vim tmux \
    jq ripgrep fd-find silversearcher-ag ack shellcheck fzf \
    imagemagick wl-clipboard xclip

  # Ubuntu ships fd as `fdfind`; expose the familiar `fd` name without clobbering
  # anything user-owned.
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
}

install_github_cli_repo() {
  log "Installing GitHub CLI (gh) from GitHub's official apt repo"
  sudo install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  fi
  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq gh
}

install_hashicorp_repo() {
  log "Installing HashiCorp tools (terraform, vault, nomad, consul, packer) from HashiCorp's apt repo"
  if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
    wget -qO- https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  fi
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq
  # terraform/vault/nomad/consul are used as CLI clients (VAULT_ADDR/NOMAD_ADDR
  # point at remote servers); we install the binaries but do not enable services.
  # packer is the infra topic's only HashiCorp-repo tool (rest of infra is in infra/install.sh).
  sudo apt-get install -y -qq terraform vault nomad consul packer
}

install_aws_cli_v2() {
  log "Installing AWS CLI v2 (official installer — apt ships v1)"
  local aws_arch tmp
  case "$ARCH" in
    arm64) aws_arch="aarch64" ;;
    *)     aws_arch="x86_64" ;;
  esac
  tmp="$(mktemp -d)"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o "${tmp}/awscliv2.zip"
  unzip -q "${tmp}/awscliv2.zip" -d "$tmp"
  # --update makes this idempotent across re-runs.
  sudo "${tmp}/aws/install" --update
  rm -rf "$tmp"
}

main() {
  install_apt_packages
  install_github_cli_repo
  install_hashicorp_repo
  install_aws_cli_v2
  log "Ubuntu base packages installed. Docker, databases, Ruby, and Node are installed by their topic installers (run via bin/dot)."
}

main "$@"
