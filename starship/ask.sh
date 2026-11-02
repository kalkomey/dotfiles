# shellcheck shell=bash
# starship topic: opt-in starship prompt. Sourced by script/ask.
# starship itself is installed by mise (see derive_answers in script/lib/common.sh).

ask_starship() {
  if [[ -z "${STARSHIP:-}" ]]; then
    STARSHIP=0
    if can_prompt; then
      echo
      read -r -p "Use the starship prompt (fast, customizable; installed with mise, plus a starter ~/.config/starship.toml if you have none)? [y/N] " ans </dev/tty || ans=""
      [[ "$ans" =~ ^[Yy] ]] && STARSHIP=1
    fi
  fi
  return 0
}
