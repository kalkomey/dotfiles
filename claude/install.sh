#!/usr/bin/env bash
#
# Claude Code status line: links claude/statusline.sh into ~/.claude and adds the
# "statusLine" key to ~/.claude/settings.json.
#
# Only runs for people who use Claude Code (a ~/.claude folder or a claude binary).
# It never overwrites anything: an existing ~/.claude/statusline.sh, an existing
# "statusLine" setting, a settings.json that is a symlink (stow) or is not valid JSON
# are all left alone, with a note. Before it edits settings.json it saves a copy in
# ~/.dotfiles-backup. Safe to re-run.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_SRC="$DOTFILES_ROOT/claude/statusline.sh"
SCRIPT_DST="$CLAUDE_DIR/statusline.sh"
STATUSLINE_JSON='{"type":"command","command":"~/.claude/statusline.sh"}'

if [[ ! -d "$CLAUDE_DIR" ]] && ! command -v claude >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  say "Claude Code not found; skipping the status line."
  exit 0
fi

# The script and this installer both need jq. macOS 15 and later ship one in /usr/bin;
# otherwise use the copy mise installed.
JQ="$(command -v jq 2>/dev/null || mise which jq 2>/dev/null || true)"
if [[ -z "$JQ" ]]; then
  warn "jq not found (the status line needs it). Install it with: mise use -g jq   then run claude/install.sh again."
  exit 0
fi

# Someone with their own status line keeps it; we do not even link our script then.
if [[ -f "$SETTINGS" && ! -L "$SETTINGS" ]] && "$JQ" -e 'has("statusLine")' "$SETTINGS" >/dev/null 2>&1; then
  if [[ "$("$JQ" -r '.statusLine.command // empty' "$SETTINGS")" != "~/.claude/statusline.sh" ]]; then
    say "~/.claude/settings.json already has its own statusLine; leaving it."
    exit 0
  fi
fi

mkdir -p "$CLAUDE_DIR"

# --- the script ---------------------------------------------------------------
if [[ -L "$SCRIPT_DST" && "$(readlink "$SCRIPT_DST")" == "$SCRIPT_SRC" ]]; then
  :   # already ours
elif [[ -e "$SCRIPT_DST" || -L "$SCRIPT_DST" ]]; then
  warn "$SCRIPT_DST already exists; leaving it (and settings.json) alone."
  exit 0
else
  ln -s "$SCRIPT_SRC" "$SCRIPT_DST"
  say "Linked ~/.claude/statusline.sh"
fi

# --- the setting --------------------------------------------------------------
if [[ ! -e "$SETTINGS" && ! -L "$SETTINGS" ]]; then
  "$JQ" -n --argjson sl "$STATUSLINE_JSON" '{statusLine: $sl}' > "$SETTINGS"
  say "Created ~/.claude/settings.json with the status line"
elif [[ -L "$SETTINGS" ]]; then
  # Writing would go through the link into someone's dotfiles repo (stow).
  warn "$SETTINGS is a symlink to $(readlink "$SETTINGS"); not editing it. Add this key yourself:"
  printf '  "statusLine": %s\n' "$STATUSLINE_JSON" >&2
elif ! "$JQ" -e 'type == "object"' "$SETTINGS" >/dev/null 2>&1; then
  warn "$SETTINGS is not a valid JSON object; not editing it. Add this key yourself:"
  printf '  "statusLine": %s\n' "$STATUSLINE_JSON" >&2
elif "$JQ" -e 'has("statusLine")' "$SETTINGS" >/dev/null 2>&1; then
  say "~/.claude/settings.json already has a statusLine; leaving it."
else
  backup="$HOME/.dotfiles-backup/claude-settings.json.$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$(dirname "$backup")"
  cp -p "$SETTINGS" "$backup"
  tmp="$(mktemp "${TMPDIR:-/tmp}/claude-settings.XXXXXX")"
  "$JQ" --argjson sl "$STATUSLINE_JSON" '. + {statusLine: $sl}' "$SETTINGS" > "$tmp"
  cat "$tmp" > "$SETTINGS"   # keeps the file's mode and owner
  rm -f "$tmp"
  say "Added the status line to ~/.claude/settings.json (original saved in ${backup/#$HOME/\~})"
fi
