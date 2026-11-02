# shellcheck shell=bash
# zsh topic: whether to install oh-my-zsh and, if so, which plugins to enable.
# Sourced by script/ask.

PLUGIN_NAMES=(git gh aws docker docker-compose terraform ruby rails bundler npm yarn fzf direnv zoxide tmux macos zsh-autosuggestions zsh-syntax-highlighting)
PLUGIN_DESCS=(
  "git aliases (gst, gco, gp...) and branch helpers"
  "GitHub CLI completions"
  "AWS CLI completions and profile helpers"
  "Docker completions"
  "docker compose aliases"
  "Terraform completions and aliases"
  "Ruby aliases"
  "Rails aliases (rails s, rails c...)"
  "Bundler aliases (be, bi...)"
  "npm completions and aliases"
  "yarn completions and aliases"
  "fzf keybindings (Ctrl-R history, Ctrl-T files)"
  "direnv hook"
  "zoxide init (z and zi commands; needs the zoxide mise tool)"
  "tmux aliases"
  "macOS helpers (ofd, pfd, showfiles...)"
  "fish-style suggestions as you type"
  "highlights valid/invalid commands as you type"
)
PLUGIN_VERS=()
PLUGIN_ON=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)

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

ask_zsh() {
  [[ -z "${SKIP_ZSH:-}" ]] || return 0

  # oh-my-zsh is optional. Answers saved before this question existed have a plugin
  # list but no OHMYZSH, and a ZSH_PLUGINS override says the same thing: both mean yes.
  # With no terminal to ask on, the default is yes, as it was before it was optional.
  if [[ -z "${OHMYZSH:-}" ]]; then
    OHMYZSH=1
    if [[ -z "${ZSH_PLUGINS:-}" ]] && can_prompt; then
      echo
      read -r -p "Install oh-my-zsh (a zsh framework with plugins for git, aws, docker and more)? [Y/n] " ans </dev/tty || ans=""
      [[ ! "$ans" =~ ^[Nn] ]] || OHMYZSH=0
    fi
  fi
  # No oh-my-zsh, so no plugins to choose and nothing for zoxide to take over `cd` through.
  if [[ "$OHMYZSH" == 0 ]]; then
    ZSH_PLUGINS=""
    ZOXIDE_CD=0
    return 0
  fi

  resolve_choice ZSH_PLUGINS PLUGIN "oh-my-zsh plugins:" 0 0

  # zoxide can take over `cd` (z/zi are always defined). Only worth asking if the
  # plugin is on. zsh/install.sh writes the choice to ~/.zshenv.
  if [[ -z "${ZOXIDE_CD:-}" ]]; then
    ZOXIDE_CD=0
    if [[ " ${ZSH_PLUGINS:-} " == *" zoxide "* ]] && can_prompt; then
      echo
      read -r -p "Replace 'cd' with zoxide (smarter cd; 'z' works either way; adds ZOXIDE_CMD_OVERRIDE=cd to ~/.zshenv)? [y/N] " ans </dev/tty || ans=""
      [[ "$ans" =~ ^[Yy] ]] && ZOXIDE_CD=1
    fi
  fi
  return 0
}
