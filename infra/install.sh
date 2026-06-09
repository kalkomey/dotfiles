#!/usr/bin/env zsh
#
# Infrastructure quality toolchain (see docs/package-matrix.md): the Terraform
# lint/security/docs tools the repos drive through pre-commit, plus ansible.
# Independently runnable and safe to re-run. On Linux it depends on pipx (from
# python/install.sh) for pre-commit and ansible.
#
# Packer is NOT here — it comes from the HashiCorp apt repo in
# script/packages/ubuntu.sh (Linux) and the Brewfile (macOS).

set -e

OS="$(uname)"
ANSIBLE_VERSION=2.18.7          # floor from ansible-ke
TERRAFORM_DOCS_VERSION=0.19.0   # no apt/installer-script; pinned release tarball

# pre-commit (latest) and ansible (pinned) via pipx. Idempotent.
install_pipx_tools() {
  if ! command -v pipx >/dev/null 2>&1; then
    echo "infra/install.sh: pipx not found — run python/install.sh first" >&2
    exit 1
  fi
  pipx install pre-commit 2>/dev/null || pipx upgrade pre-commit || true
  pipx install "ansible==${ANSIBLE_VERSION}" 2>/dev/null \
    || pipx install --force "ansible==${ANSIBLE_VERSION}" || true
}

if [[ "$OS" == "Darwin" ]]; then
  # macOS: declared in the Brewfile and installed by `brew bundle`. Install
  # defensively so this topic is runnable on its own.
  if command -v brew >/dev/null 2>&1; then
    brew install tflint tfsec trivy terraform-docs packer pre-commit ansible
  else
    echo "infra/install.sh: Homebrew missing; run homebrew/install.sh first" >&2
    exit 1
  fi

elif [[ "$OS" == "Linux" ]]; then
  arch="$(dpkg --print-architecture)"   # amd64 | arm64

  # tflint, tfsec, trivy: official install scripts (fetch latest, install to
  # /usr/local/bin). These are remote-script pipes — the documented install path.
  curl -fsSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  curl -fsSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sudo sh -s -- -b /usr/local/bin

  # terraform-docs: pinned release tarball -> /usr/local/bin.
  tmp="$(mktemp -d)"
  curl -fsSL "https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${arch}.tar.gz" \
    -o "${tmp}/terraform-docs.tar.gz"
  tar -xzf "${tmp}/terraform-docs.tar.gz" -C "$tmp" terraform-docs
  sudo install -m 0755 "${tmp}/terraform-docs" /usr/local/bin/terraform-docs
  rm -rf "$tmp"

  install_pipx_tools

else
  echo "infra/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi
