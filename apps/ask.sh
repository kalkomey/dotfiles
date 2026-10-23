# shellcheck shell=bash
# apps topic: which desktop applications to install from Homebrew casks.
# Sourced by script/ask. Same parallel-array shape as mise/ask.sh; the names are
# Homebrew cask names, so what you see here is what `brew install --cask` takes.

APP_NAMES=(cmux ghostty kitty obsidian rectangle sequel-ace sublime-text tldraw zed)
APP_DESCS=(
  "Ghostty-based terminal with vertical tabs, built for AI coding agents"
  "Terminal emulator with a native UI and GPU acceleration"
  "GPU-based terminal emulator"
  "Notes on top of a local folder of Markdown files"
  "Move and resize windows with keyboard shortcuts or snap areas"
  "MySQL/MariaDB database client"
  "Text editor for code, markup and prose"
  "Offline canvas and diagram editor (.tldr files)"
  "Fast, multiplayer code editor"
)
APP_VERS=()
APP_ON=(0 0 0 0 0 0 0 0 0)   # nothing on by default: IT's machine image already installs the standard apps

ask_apps() {
  # "none" is how a saved "no apps" answer is stored (empty means unanswered).
  if [[ "${APPS:-}" != none ]]; then
    resolve_choice APPS APP "Applications (installed via Homebrew casks):" 0 3
  fi
  APPS="${APPS:-none}"
  return 0
}
