# shellcheck shell=bash
# zsh topic: which oh-my-zsh plugins to enable. Sourced by script/ask.

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
