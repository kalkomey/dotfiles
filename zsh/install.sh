#!/usr/bin/env bash
#
# Shell setup beyond the prompt: oh-my-zsh (only if you chose it, and only for its theme),
# the zoxide `cd` setting, zsh-autosuggestions and zsh-syntax-highlighting (if chosen), and
# shell completions. Reads the answers saved by script/ask. The ~/.zprofile block (Homebrew
# + mise shims) is written either way, and tool integrations (fzf, zoxide, direnv) are set
# up by zsh/integrations.sh, which ~/.zshrc sources.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"
install_prelude

if [[ -n "${SKIP_ZSH:-}" ]]; then
  say "SKIP_ZSH set; skipping oh-my-zsh and shell setup."
  exit 0
fi

# oh-my-zsh is only used for its theme: no plugins, no extra clones. Everything else
# (fzf, zoxide, direnv, completions) is set up below or in zsh/integrations.sh, whether or
# not oh-my-zsh is installed.
install_ohmyzsh() {
  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  [[ ! -d "$ZSH" ]] || return 0
  # Download first, so a failed download is an error and not an empty script that "succeeds".
  omz_installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    || die "Could not download the oh-my-zsh installer."
  # RUNZSH/CHSH stop it starting a shell or changing yours; KEEP_ZSHRC keeps our .zshrc.
  # Its banner and clone progress go to a log, shown only if it fails.
  quiet_run "Installing oh-my-zsh..." env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$omz_installer"
}

if [[ "$OHMYZSH" == 0 ]]; then
  if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
    say "You skipped oh-my-zsh; ${ZSH:-$HOME/.oh-my-zsh} is left in place but .zshrc will not load it."
  else
    say "You skipped oh-my-zsh; not installing it."
  fi
else
  install_ohmyzsh
fi

# Replace `cd` with zoxide: zoxide reads ZOXIDE_CMD_OVERRIDE (see zsh/integrations.sh),
# and ~/.zshenv is read before ~/.zshrc. Append (or create) it, once.
if [[ "${ZOXIDE_CD:-0}" == 1 ]]; then
  if [[ -L "$HOME/.zshenv" ]]; then
    # Appending would write through the link into someone's dotfiles repo (stow).
    warn "~/.zshenv is a symlink to $(readlink "$HOME/.zshenv"); not editing it. Add this line to it yourself: export ZOXIDE_CMD_OVERRIDE=cd"
  elif grep -qs '^export ZOXIDE_CMD_OVERRIDE=' "$HOME/.zshenv"; then
    say "~/.zshenv already sets ZOXIDE_CMD_OVERRIDE; leaving it."
  else
    say "Adding ZOXIDE_CMD_OVERRIDE=cd to ~/.zshenv"
    # Keep a prior file's last line intact if it lacks a trailing newline.
    [[ ! -s "$HOME/.zshenv" || -z "$(tail -c1 "$HOME/.zshenv")" ]] || echo >> "$HOME/.zshenv"
    echo 'export ZOXIDE_CMD_OVERRIDE=cd' >> "$HOME/.zshenv"
  fi
fi

# Suggestions and highlighting as you type; zsh/typing.sh loads them if they are installed.
if [[ "${ZSH_TYPING:-0}" == 1 ]]; then
  brew_install_missing zsh-autosuggestions zsh-syntax-highlighting \
    || warn "Could not install zsh-autosuggestions or zsh-syntax-highlighting."
fi

# Completions for tools that print their own zsh completion script (gh, docker, colima,
# op, rg, mise). They go to ~/.config/dotfiles/completions, which ~/.zshrc puts on fpath
# before compinit. Regenerated on every run, so they follow tool upgrades. A tool that is
# missing, or whose command fails, is skipped. (terraform, vault, nomad, consul and aws
# complete through bashcompinit in zsh/integrations.sh instead.)
generate_completions() {
  local dir="$CONFIG_DIR/completions" bins spec name cmd tmp made=()
  mkdir -p "$dir"
  # mise's tools are not on this script's PATH; add their directories.
  bins="$(mise bin-paths 2>/dev/null | tr '\n' ':' || true)"
  for spec in "gh|gh completion -s zsh" "docker|docker completion zsh" \
              "colima|colima completion zsh" "op|op completion zsh" \
              "rg|rg --generate complete-zsh" "mise|mise completion zsh"; do
    name="${spec%%|*}"; cmd="${spec#*|}"
    (PATH="$bins$PATH"; command -v "$name" >/dev/null 2>&1) || continue
    tmp="$(mktemp "${TMPDIR:-/tmp}/completion.XXXXXX")"
    # shellcheck disable=SC2086  # $cmd is a command and its arguments
    if (PATH="$bins$PATH"; $cmd) >"$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
      mv "$tmp" "$dir/_$name"
      chmod 644 "$dir/_$name"
      made+=("$name")
    else
      rm -f "$tmp"
    fi
  done
  if (( ${#made[@]} )); then
    say "Wrote shell completions for: ${made[*]}"
  fi
}
generate_completions

# mise shims for login shells, scripts, git hooks and IDE tasks. ~/.zshrc only runs
# in interactive shells, where `mise activate` does the job; ~/.zprofile is read by
# every login shell, after macOS's /etc/zprofile has reordered PATH (so not
# ~/.zshenv, which runs before it). Homebrew goes first in the block so shims, added
# after it, win over Homebrew's ruby/node. One delimited block, appended once; the
# versions resolve the same way as in an interactive shell because both follow mise's config.
ZPROFILE_BEGIN='# >>> dotfiles: Homebrew, then mise shims (managed by zsh/install.sh) >>>'
ZPROFILE_BLOCK="$ZPROFILE_BEGIN
if [ -x /opt/homebrew/bin/brew ]; then
  eval \"\$(/opt/homebrew/bin/brew shellenv)\"
elif [ -x /usr/local/bin/brew ]; then
  eval \"\$(/usr/local/bin/brew shellenv)\"
fi
if command -v mise >/dev/null 2>&1; then
  eval \"\$(mise activate zsh --shims)\"
fi
# <<< dotfiles <<<"
if [[ -L "$HOME/.zprofile" ]]; then
  warn "~/.zprofile is a symlink to $(readlink "$HOME/.zprofile"); not editing it. To get mise in login shells and scripts, add this to it yourself:"
  printf '%s\n' "$ZPROFILE_BLOCK" >&2
elif grep -qsF -- "$ZPROFILE_BEGIN" "$HOME/.zprofile"; then
  say "~/.zprofile already has the mise shims block; leaving it."
else
  say "Adding Homebrew + mise shims to ~/.zprofile (login shells and scripts)"
  [[ ! -s "$HOME/.zprofile" || -z "$(tail -c1 "$HOME/.zprofile")" ]] || echo >> "$HOME/.zprofile"
  printf '%s\n' "$ZPROFILE_BLOCK" >> "$HOME/.zprofile"
fi

mkdir -p "$CONFIG_DIR"
say "Writing $CONFIG_DIR/ohmyzsh.zsh"
{
  echo "# Generated by zsh/install.sh; run script/ask with RECONFIGURE=1 to change."
  if [[ "$OHMYZSH" == 0 ]]; then
    # zsh/zshrc.symlink skips oh-my-zsh when it sees this, even if ~/.oh-my-zsh exists.
    echo "DOTFILES_OHMYZSH=0"
  else
    echo "DOTFILES_OHMYZSH=1"
  fi
} > "$CONFIG_DIR/ohmyzsh.zsh"
# Older versions wrote the plugin list here; it is no longer read.
rm -f "$CONFIG_DIR/zsh-plugins.zsh"
