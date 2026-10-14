# shellcheck shell=bash
# zsh topic: which oh-my-zsh plugins to enable. Sourced by script/ask.

PLUGIN_NAMES=(git gh aws docker docker-compose terraform ruby rails bundler npm yarn fzf direnv tmux macos zsh-autosuggestions zsh-syntax-highlighting)
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
  "tmux aliases"
  "macOS helpers (ofd, pfd, showfiles...)"
  "fish-style suggestions as you type"
  "highlights valid/invalid commands as you type"
)
PLUGIN_VERS=()
PLUGIN_ON=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)

ask_zsh() {
  [[ -z "${SKIP_ZSH:-}" ]] || return 0
  resolve_choice ZSH_PLUGINS PLUGIN "oh-my-zsh plugins:" 0 0
}
