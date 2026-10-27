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
