#!/usr/bin/env bash
#
# One-line installer for Kalkomey's dotfiles:
#
#   curl -fsSL https://raw.githubusercontent.com/kalkomey/dotfiles/master/setup.sh | bash
#
# Options for script/bootstrap go after `-s --`, for example a preview that
# changes nothing:
#
#   curl -fsSL https://raw.githubusercontent.com/kalkomey/dotfiles/master/setup.sh | bash -s -- --dry-run
#
# What it does: makes sure git is there (Xcode Command Line Tools), clones the
# repo into ~/.dotfiles (or fast-forwards an existing clean checkout), then runs
# script/bootstrap with your terminal as its input. That last part matters: when
# this script arrives on a pipe, the questions would otherwise try to read from it.
#
# Environment:
#   DOTFILES_BRANCH=master    branch to install (default: master)
#   DOTFILES_REPO=<url>       repository to clone (default: kalkomey/dotfiles on GitHub)
#   DOTFILES_SKIP_UPDATE=1    use ~/.dotfiles exactly as it is (for developing it)
#
# Everything is inside main(), called on the last line, so a download that is cut
# off partway runs nothing.

set -euo pipefail

main() {
  local repo="${DOTFILES_REPO:-https://github.com/kalkomey/dotfiles.git}"
  local branch="${DOTFILES_BRANCH:-master}"
  local dir="$HOME/.dotfiles"   # bin/dot and the Brewfile step expect this path
  local origin current

  say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
  die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

  [[ "$(uname -s)" == "Darwin" ]] || die "This installer supports macOS only."
  [[ $EUID -ne 0 ]] || die "Do not run as root."

  # git comes with the Xcode Command Line Tools on a fresh Mac.
  if ! xcode-select -p >/dev/null 2>&1; then
    say "Installing Xcode Command Line Tools (a dialog will appear)..."
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  fi
  command -v git >/dev/null 2>&1 || die "git is not available."

  if [[ -n "${DOTFILES_SKIP_UPDATE:-}" ]]; then
    [[ -e "$dir/script/bootstrap" ]] || die "DOTFILES_SKIP_UPDATE is set but $dir/script/bootstrap does not exist."
    say "Using $dir as it is (DOTFILES_SKIP_UPDATE)."
  elif [[ -e "$dir/.git" ]]; then
    # An existing checkout: update it only if that cannot hurt anything of theirs.
    origin="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
    case "$origin" in
      *kalkomey/dotfiles*|"$repo") ;;
      *) die "$dir is a checkout of '${origin:-no remote}', not $repo. Move it aside, or set DOTFILES_REPO." ;;
    esac
    [[ -z "$(git -C "$dir" status --porcelain --untracked-files=no)" ]] \
      || die "$dir has uncommitted changes. Commit or stash them and run this again."
    current="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
    [[ "$current" == "$branch" ]] \
      || die "$dir is on branch '$current', not '$branch'. Check out '$branch', or set DOTFILES_BRANCH=$current."
    say "Updating $dir ($branch)..."
    git -C "$dir" fetch --quiet origin "$branch"
    git -C "$dir" merge --ff-only --quiet "origin/$branch" \
      || die "$dir has diverged from origin/$branch (local commits and new upstream ones), so it cannot be fast-forwarded. Rebase or merge it yourself, then run this again."
  elif [[ -e "$dir" || -L "$dir" ]]; then
    die "$dir exists but is not a git checkout. Move it aside and run this again."
  else
    say "Cloning $repo ($branch) into $dir..."
    git clone --quiet --branch "$branch" "$repo" "$dir"
  fi

  cd "$dir"
  # Give bootstrap the terminal, not this script's pipe. With no terminal (CI),
  # it runs unattended: your existing files are kept and defaults are used.
  if { : </dev/tty; } 2>/dev/null; then
    exec bash script/bootstrap "$@" </dev/tty
  else
    exec bash script/bootstrap "$@" </dev/null
  fi
}

main "$@"
