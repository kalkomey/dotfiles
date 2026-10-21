# shellcheck shell=bash
#
# Shared helpers for script/ask and the topic installers (mise/, fonts/,
# neovim/, zsh/). Source this file; do not execute it.
#
# macOS ships bash 3.2, so everything here avoids associative arrays, namerefs
# and other bash 4+ features (lists are parallel arrays; see the pickers).

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

DRY_RUN="${DRY_RUN:-0}"
DRY_NOTES=()
dry() { [[ "$DRY_RUN" == 1 ]]; }

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This script supports macOS only."
  [[ $EUID -ne 0 ]] || die "Do not run as root."
}

# --- Saved answers -----------------------------------------------------------
# Answers live outside the repo so personal choices are never committed.
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
CHOICES_FILE="$CONFIG_DIR/install-choices"
ANSWER_VARS="MISE_LANGUAGES MISE_TOOLS ZSH_PLUGINS ZOXIDE_CD NEOVIM FONTS"
SAVED_VARS=""

# load_saved_answers [install]
# Fills any answer variable that is not already set (env overrides win) from the
# saved file. `ask` honors RECONFIGURE=1 (ignore saved answers); the installers
# pass "install" and always trust what `ask` saved.
load_saved_answers() {
  local v line
  [[ -r "$CHOICES_FILE" ]] || return 0
  [[ "${1:-}" == install || -z "${RECONFIGURE:-}" ]] || return 0
  for v in $ANSWER_VARS; do
    [[ -z "${!v:-}" ]] || continue
    line="$(grep "^$v=" "$CHOICES_FILE" || true)"
    if [[ -n "$line" ]]; then
      printf -v "$v" '%s' "${line#*=}"
      SAVED_VARS="$SAVED_VARS $v"
    fi
  done
}

# FONTS is "none", not empty, when no fonts were chosen (empty means "unanswered").
save_answers() {
  mkdir -p "$CONFIG_DIR"
  {
    echo "MISE_LANGUAGES=$MISE_LANGUAGES"
    echo "MISE_TOOLS=$MISE_TOOLS"
    echo "ZSH_PLUGINS=${ZSH_PLUGINS:-}"
    echo "ZOXIDE_CD=${ZOXIDE_CD:-0}"
    echo "NEOVIM=$NEOVIM"
    echo "FONTS=${FONTS:-none}"
  } > "$CHOICES_FILE"
}

normalize_answers() {
  ZSH_PLUGINS="${ZSH_PLUGINS:-}"
  ZOXIDE_CD="${ZOXIDE_CD:-0}"
  NEOVIM="${NEOVIM:-0}"
  FONTS="${FONTS:-none}"
  [[ "$FONTS" != none ]] || FONTS=""
}

# Things implied by the answers rather than asked. Each addition is recorded in
# DERIVED so `script/ask --dry-run` can show it.
DERIVED=()
derive_answers() {
  # Elixir needs Erlang. Add it if missing, and skip the slow/fragile optional
  # Erlang pieces (Java bindings, wx GUI, ODBC) that nobody needs here.
  if [[ " $MISE_LANGUAGES " == *" elixir"* && " $MISE_LANGUAGES " != *" erlang"* ]]; then
    MISE_LANGUAGES="erlang@latest $MISE_LANGUAGES"
    DERIVED+=("language erlang@latest (required by elixir)")
  fi
  if [[ " $MISE_LANGUAGES " == *" erlang"* ]]; then
    export KERL_CONFIGURE_OPTIONS="${KERL_CONFIGURE_OPTIONS:---without-javac --without-wx --without-odbc}"
  fi
}

# --- Prerequisites -----------------------------------------------------------
# Put Homebrew on PATH if it is installed. Returns 1 if it is not.
load_brew() {
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && eval "$("$b" shellenv)" && return 0
  done
  return 1
}

# Prints a note if mise is installed somewhere other than Homebrew (for example the
# curl installer's ~/.local/bin): 'brew upgrade' will not update it, and a login
# shell may not have its directory on PATH.
mise_source_note() {
  local m prefix
  m="$(command -v mise 2>/dev/null || true)"
  [[ -n "$m" ]] || return 0
  prefix="$(brew --prefix 2>/dev/null || true)"
  [[ -n "$prefix" && "$m" != "$prefix"/* ]] || return 0
  printf "mise is at %s, not installed by Homebrew, so 'brew upgrade' will not update it. To switch: rm '%s' && brew install mise" "$m" "$m"
}

# Xcode CLT, Homebrew and mise. Under --dry-run this only looks.
ensure_prereqs() {
  local t
  if dry; then
    load_brew || true
    for t in brew mise; do
      command -v "$t" >/dev/null 2>&1 || DRY_NOTES+=("$t is not installed, so checks that need it were skipped")
    done
    t="$(mise_source_note)"; [[ -z "$t" ]] || DRY_NOTES+=("$t")
    return 0
  fi

  if ! xcode-select -p >/dev/null 2>&1; then
    say "Installing Xcode Command Line Tools (a dialog will appear)..."
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  fi

  if ! load_brew; then
    say "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew || die "Homebrew installed but not found on PATH."
  fi

  if ! command -v mise >/dev/null 2>&1; then
    say "Installing mise..."
    brew install mise
  fi
  t="$(mise_source_note)"; [[ -z "$t" ]] || warn "$t"
}

# Common start for every topic installer: load the saved answers (running
# script/ask first if there are none), and make Homebrew and mise available.
install_prelude() {
  require_macos
  dry && die "--dry-run is only supported by script/ask."
  load_brew || true
  { command -v brew >/dev/null 2>&1 && command -v mise >/dev/null 2>&1; } || ensure_prereqs
  load_saved_answers install
  if [[ ! -r "$CHOICES_FILE" ]]; then
    say "No saved answers yet; running script/ask first..."
    "$DOTFILES_ROOT/script/ask"
    load_saved_answers install
  fi
  normalize_answers
  derive_answers
}

# --- Pickers -----------------------------------------------------------------
can_prompt() { { : </dev/tty; } 2>/dev/null; }

# True if Homebrew has the Nerd Font cask for a short name (fira-code -> font-fira-code-nerd-font).
valid_font() { { dry && ! command -v brew >/dev/null 2>&1; } && return 0; brew info --cask "font-$1-nerd-font" >/dev/null 2>&1; }

# True if mise can resolve the spec (tool name and, if given, version).
# "latest"/"lts"/"stable" are aliases `mise latest` may not accept for every
# tool, so for those only the tool name is checked.
valid_spec() {
  local spec="$1" name="${1%%@*}" ver=""
  { dry && ! command -v mise >/dev/null 2>&1; } && return 0   # dry run without mise: can't check
  [[ "$spec" == *@* ]] && ver="${spec#*@}"
  case "$ver" in latest|lts|stable) spec="$name" ;; esac
  [[ -n "$(mise latest "$spec" 2>/dev/null)" ]]
}

# Generic checklist picker over the ITEM_* arrays.
#   $1 = title, $2 = 1 if items carry editable versions (ITEM_VERS)
# Reads from /dev/tty because stdin is the script under `curl | bash`.
# Sets PICKED to a space-separated list (name or name@version).
pick_items() {
  local title="$1" versions="$2" validate="$3" i n tok ans mark ver name found spec bad
  # Optional paging (set by the caller): only the first PICK_INITIAL items are
  # shown until the user types 'm'; items they add by hand are always shown.
  local base=${#ITEM_NAMES[@]} initial=${PICK_INITIAL:-0} shown
  (( initial > 0 && initial < base )) || initial=$base
  shown=$initial
  while true; do
    echo
    echo "$title"
    [[ -z "${PICK_NOTE:-}" ]] || echo "$PICK_NOTE"
    for i in "${!ITEM_NAMES[@]}"; do
      (( i < shown || i >= base )) || continue
      mark=" "; [[ "${ITEM_ON[$i]}" == 1 ]] && mark="x"
      if [[ "$versions" == 1 ]]; then
        printf '  %2d) [%s] %-8s %-8s %s\n' "$((i + 1))" "$mark" "${ITEM_NAMES[$i]}" "${ITEM_VERS[$i]}" "${ITEM_DESCS[$i]}"
      else
        printf '  %2d) [%s] %-22s %s\n' "$((i + 1))" "$mark" "${ITEM_NAMES[$i]}" "${ITEM_DESCS[$i]}"
      fi
    done
    echo
    if [[ "$versions" == 1 ]]; then
      echo "  Type numbers to select or deselect (e.g. 3 4)."
      echo "  Type name@version for a specific version (e.g. ruby@4.0.7), or to add a tool not in the list (e.g. php@8.4, zig@latest)."
    else
      if [[ "$validate" == 2 ]]; then echo "  Toggle: numbers (e.g. 4 5)   Add another Nerd Font by short name (e.g. hack)"
      else echo "  Toggle: numbers (e.g. 4 5)   Add any mise tool: name (e.g. bat, yq)"; fi
    fi
    if (( shown < base )); then
      echo "  'm' = show more ($((base - shown)) more available)"
    elif (( initial < base )); then
      echo "  'l' = show less"
    fi
    read -r -p "  'a' = all, 'n' = none, Enter = accept: " ans </dev/tty || break
    if [[ -z "$ans" ]]; then
      # On accept, check anything the user typed or edited against mise so a
      # typo is caught now, not after a long compile.
      bad=0
      if [[ "$validate" == 1 || "$validate" == 2 ]]; then
        for i in "${!ITEM_NAMES[@]}"; do
          [[ "${ITEM_ON[$i]}" == 1 && "${ITEM_CHK[$i]:-0}" == 1 ]] || continue
          if [[ "$versions" == 1 ]]; then spec="${ITEM_NAMES[$i]}@${ITEM_VERS[$i]}"; else spec="${ITEM_NAMES[$i]}"; fi
          if [[ "$validate" == 2 ]]; then
            valid_font "$spec" || { warn "No Nerd Font cask 'font-$spec-nerd-font' in Homebrew. Fix it, or toggle it off."; bad=1; }
          elif ! valid_spec "$spec"; then
            warn "'$spec' not found in mise (check the name/version). Fix it, or toggle it off."
            bad=1
          fi
        done
      fi
      (( bad )) || break
      continue
    fi
    case "$ans" in
      m|M) shown=$(( shown + 15 )); (( shown <= base )) || shown=$base ;;
      l|L) shown=$initial ;;
      a|A) for i in "${!ITEM_ON[@]}"; do ITEM_ON[$i]=1; done ;;
      n|N) for i in "${!ITEM_ON[@]}"; do ITEM_ON[$i]=0; done ;;
      *)
        for tok in $ans; do
          n="${tok%%=*}"
          if [[ "$n" =~ ^[0-9]+$ ]]; then
            (( n >= 1 && n <= ${#ITEM_NAMES[@]} )) || continue
            i=$((n - 1))
            (( i < shown || i >= base )) || continue   # hidden; type 'm' to reveal
            if [[ "$tok" == *=* && "$versions" == 1 ]]; then
              ver="${tok#*=}"
              if [[ -n "$ver" ]]; then ITEM_VERS[$i]="$ver"; ITEM_ON[$i]=1; ITEM_CHK[$i]=1; fi
            else
              ITEM_ON[$i]=$(( 1 - ITEM_ON[$i] ))
            fi
          elif [[ "$tok" =~ ^[A-Za-z][A-Za-z0-9._:/-]*(@[^[:space:]]+)?$ ]]; then
            # Free-form entry: name or name@version (any mise tool, e.g. php@8.4,
            # aqua:owner/repo). Re-entering a listed name just enables it.
            # In unversioned lists (tools) keep name@version as the name.
            name="$tok"; ver=""
            if [[ "$versions" == 1 ]]; then
              name="${tok%%@*}"
              [[ "$tok" == *@* ]] && ver="${tok#*@}"
            fi
            found=-1
            for i in "${!ITEM_NAMES[@]}"; do
              [[ "${ITEM_NAMES[$i]}" == "$name" ]] && found=$i
            done
            if (( found >= 0 )); then
              ITEM_ON[$found]=1
              if [[ -n "$ver" && "$versions" == 1 ]]; then ITEM_VERS[$found]="$ver"; ITEM_CHK[$found]=1; fi
            else
              i=${#ITEM_NAMES[@]}
              ITEM_NAMES[$i]="$name"; ITEM_DESCS[$i]="(custom)"; ITEM_ON[$i]=1; ITEM_CHK[$i]=1
              [[ "$versions" == 1 ]] && ITEM_VERS[$i]="${ver:-latest}"
            fi
          fi
        done ;;
    esac
  done
  PICKED=""
  for i in "${!ITEM_NAMES[@]}"; do
    [[ "${ITEM_ON[$i]}" == 1 ]] || continue
    if [[ "$versions" == 1 ]]; then
      PICKED="$PICKED ${ITEM_NAMES[$i]}@${ITEM_VERS[$i]}"
    else
      PICKED="$PICKED ${ITEM_NAMES[$i]}"
    fi
  done
  PICKED="${PICKED# }"
}

# Resolve one list: env override > interactive picker > defaults.
#   $1 = env var name, $2 = prefix (LANG|TOOL|PLUGIN), $3 = title,
#   $4 = versions?, $5 = validate against mise?
resolve_choice() {
  local var="$1" prefix="$2" title="$3" versions="$4" validate="$5" i spec bad=0
  if [[ -n "${!var:-}" ]]; then
    # Env override: validate everything and fail fast.
    if [[ "$validate" == 1 && " $SAVED_VARS " != *" $var "* ]]; then
      for spec in ${!var}; do
        valid_spec "$spec" || { warn "$var: '$spec' not found in mise"; bad=1; }
      done
      (( bad == 0 )) || die "Fix $var and re-run."
    fi
    return 0
  fi
  # Copy the prefixed arrays into the generic ITEM_* arrays.
  eval "ITEM_NAMES=(\"\${${prefix}_NAMES[@]}\"); ITEM_DESCS=(\"\${${prefix}_DESCS[@]}\"); ITEM_ON=(\"\${${prefix}_ON[@]}\")"
  if [[ "$versions" == 1 ]]; then eval "ITEM_VERS=(\"\${${prefix}_VERS[@]}\")"; else ITEM_VERS=(); fi
  ITEM_CHK=()
  if can_prompt; then
    pick_items "$title" "$versions" "$validate"
  else
    PICKED=""
    for i in "${!ITEM_NAMES[@]}"; do
      [[ "${ITEM_ON[$i]}" == 1 ]] || continue
      if [[ "$versions" == 1 ]]; then PICKED="$PICKED ${ITEM_NAMES[$i]}@${ITEM_VERS[$i]}"
      else PICKED="$PICKED ${ITEM_NAMES[$i]}"; fi
    done
    PICKED="${PICKED# }"
  fi
  printf -v "$var" '%s' "$PICKED"
}
