# shellcheck shell=bash
# zsh topic: how the shell is set up. Sourced by script/ask.
#
# oh-my-zsh is optional and used only for its theme; it loads no plugins. The tool
# integrations (fzf, zoxide, direnv, completions) live in zsh/integrations.sh and work
# whichever of oh-my-zsh and starship you pick, or neither.

# One question for the two things that style the shell: oh-my-zsh (a framework with
# plugins and a theme) and starship (a prompt). Many people want one or the other, some
# both (starship is sourced after oh-my-zsh, so it wins the prompt), some neither. Skipped
# when either answer is already known (env var or saved answer); ask_zsh and ask_starship
# then ask about whichever is still unanswered on its own. With no terminal to ask on,
# the default is oh-my-zsh only, as before starship existed. With one, nothing is
# preselected: the person has to choose (Ctrl-D, end of input, means neither).
ask_shell() {
  [[ -z "${SKIP_ZSH:-}" && -z "${OHMYZSH:-}" && -z "${STARSHIP:-}" ]] || return 0
  OHMYZSH=1
  STARSHIP=0
  can_prompt || return 0
  local ans
  echo
  echo "Shell setup:"
  echo "  1) oh-my-zsh  a zsh framework with plugins (git, aws, docker...) and a theme"
  echo "  2) starship   a fast, customizable prompt (https://starship.rs)"
  echo "  3) both       oh-my-zsh plugins, with the starship prompt instead of its theme"
  echo "  4) neither"
  while :; do
    # End of input (Ctrl-D) would loop forever; treat it as "neither".
    read -r -p "Choose 1-4: " ans </dev/tty || { OHMYZSH=0; STARSHIP=0; break; }
    case "$ans" in
      1) OHMYZSH=1; STARSHIP=0; break ;;
      2) OHMYZSH=0; STARSHIP=1; break ;;
      3) OHMYZSH=1; STARSHIP=1; break ;;
      4) OHMYZSH=0; STARSHIP=0; break ;;
      *) echo "Please enter 1, 2, 3 or 4 (there is no default)." ;;
    esac
  done
}

# oh-my-zsh when it was not settled by ask_shell above (one of OHMYZSH and STARSHIP was
# already known). Only a theme, so there is no point in it next to starship.
ask_zsh() {
  [[ -z "${SKIP_ZSH:-}" ]] || return 0
  if [[ -z "${OHMYZSH:-}" ]]; then
    OHMYZSH=0
    if [[ "${STARSHIP:-0}" != 1 ]] && can_prompt; then
      echo
      read -r -p "Install oh-my-zsh (used only for its prompt theme)? [y/N] " ans </dev/tty || ans=""
      [[ ! "$ans" =~ ^[Yy] ]] || OHMYZSH=1
    fi
  fi
  return 0
}

# Two small options that do not depend on oh-my-zsh.
ask_shell_extras() {
  [[ -z "${SKIP_ZSH:-}" ]] || return 0

  # zoxide can take over `cd` (z and zi are always there). zsh/install.sh writes the
  # choice to ~/.zshenv. Only asked if the zoxide tool is being installed.
  if [[ -z "${ZOXIDE_CD:-}" ]]; then
    ZOXIDE_CD=0
    if [[ " ${MISE_TOOLS:-} " == *" zoxide "* ]] && can_prompt; then
      echo
      read -r -p "Replace 'cd' with zoxide (smarter cd; 'z' works either way; adds ZOXIDE_CMD_OVERRIDE=cd to ~/.zshenv)? [y/N] " ans </dev/tty || ans=""
      [[ "$ans" =~ ^[Yy] ]] && ZOXIDE_CD=1
    fi
  fi

  # zsh-autosuggestions and zsh-syntax-highlighting, installed from Homebrew.
  if [[ -z "${ZSH_TYPING:-}" ]]; then
    ZSH_TYPING=0
    if can_prompt; then
      echo
      read -r -p "Suggest commands from history and highlight them as you type (zsh-autosuggestions, zsh-syntax-highlighting)? [Y/n] " ans </dev/tty || ans=""
      [[ "$ans" =~ ^[Nn] ]] || ZSH_TYPING=1
    fi
  fi
  return 0
}
