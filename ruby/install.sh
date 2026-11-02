#!/usr/bin/env bash
#
# Ruby gems that need Kalkomey's private gem server (Gemfury): aios-claude, which
# also installs aios as a dependency.
#
# Public gems (bundler, rails) are in ruby/default-gems.symlink and install with every
# Ruby. These two cannot go there, because the source URL needs your Gemfury token and
# a tracked file must never hold a token. The token comes from the environment:
# BUNDLE_GEM__FURY__IO, which belongs in ~/.zshrc.local. It can be the token itself or
# a 1Password reference (op://Vault/Item/field), which is read with the 1Password CLI.
#
# Skips with a note (never fails the install) when mise or Ruby is missing, the token
# is not set, or a 1Password reference cannot be read (no `op`, or not signed in). Safe to re-run: it does nothing when aios-claude is already installed.
#   bash ~/.dotfiles/ruby/install.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"

GEMS=(aios-claude)
SOURCE_HOST="gem.fury.io/kalkomey/"

if ! command -v mise >/dev/null 2>&1; then
  say "mise not found; skipping the private gems."
  exit 0
fi
if ! mise which gem >/dev/null 2>&1; then
  say "No mise-managed Ruby found; skipping the private gems."
  exit 0
fi

if [[ -z "${BUNDLE_GEM__FURY__IO:-}" ]]; then
  warn "BUNDLE_GEM__FURY__IO is not set, so ${GEMS[*]} was not installed."
  warn "Put 'export BUNDLE_GEM__FURY__IO=\"<your key or op:// reference>\"' in ~/.zshrc.local, open a new terminal, then run: bash ~/.dotfiles/ruby/install.sh"
  exit 0
fi

# A 1Password reference is resolved here. Nothing is printed except on failure, and
# never the secret itself.
FURY_TOKEN="$BUNDLE_GEM__FURY__IO"
if [[ "$FURY_TOKEN" == op://* ]]; then
  OP="$(command -v op 2>/dev/null || mise which op 2>/dev/null || true)"
  if [[ -z "$OP" ]]; then
    warn "BUNDLE_GEM__FURY__IO is a 1Password reference, but the 1Password CLI (op) was not found. Install it with: mise use -g 1password-cli   then run: bash ~/.dotfiles/ruby/install.sh"
    exit 0
  fi
  if ! FURY_TOKEN="$("$OP" read "$BUNDLE_GEM__FURY__IO" 2>/dev/null)" || [[ -z "$FURY_TOKEN" ]]; then
    warn "Could not read $BUNDLE_GEM__FURY__IO with 1Password. Unlock 1Password (or sign in with op signin), then run: bash ~/.dotfiles/ruby/install.sh"
    exit 0
  fi
fi

for gem_name in "${GEMS[@]}"; do
  if mise exec -- gem list --installed --exact "$gem_name" >/dev/null 2>&1; then
    say "$gem_name is already installed."
    continue
  fi
  if dry; then
    echo "  gem install $gem_name   (from https://<token>@$SOURCE_HOST)"
    continue
  fi
  say "Installing $gem_name from the Kalkomey gem server..."
  # Keep the token out of the terminal and logs: capture the output, and if the
  # install fails, print it with the token masked.
  if ! out="$(mise exec -- gem install "$gem_name" --source "https://${FURY_TOKEN}@${SOURCE_HOST}" 2>&1)"; then
    printf '%s\n' "${out//${FURY_TOKEN}/***}" >&2
    warn "Could not install $gem_name. Check the key in BUNDLE_GEM__FURY__IO, then run: bash ~/.dotfiles/ruby/install.sh"
    continue
  fi
  say "Installed $gem_name."
done
