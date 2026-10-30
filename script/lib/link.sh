# shellcheck shell=bash
#
# Link the repo's *.symlink files into $HOME without clobbering what is already
# there: a plain dotfile, or a symlink from GNU Stow or a similar tool.
# Sourced by script/bootstrap; needs say/warn/dry from common.sh.
# bash 3.2 safe (no associative arrays, no namerefs).
#
# The rule: nothing is ever deleted. Anything we replace or merge is first moved
# into $BACKUP_DIR, mirroring its path under $HOME.
#
# Env:
#   DOTFILES_LINK=ask|keep|new   what to do on a conflict (default: ask; with no
#                                terminal to ask on, "ask" falls back to keep)
#   MERGE_TOOL="vimdiff"         diff editor for [m]erge; the first pane is your
#                                file. e.g. MERGE_TOOL="code --wait --diff"
#   DOTFILES_BACKUP_DIR=...      default ~/.dotfiles-backup/<timestamp>
#   LINK_TTY=/dev/tty            where answers are read from (for tests)

BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
LINK_POLICY="${DOTFILES_LINK:-ask}"
LINK_TTY="${LINK_TTY:-/dev/tty}"
LINK_ALL=""            # "keep" or "new" once the user answers K or N
LINK_INTERACTIVE=0
LINK_LOG=()
LINK_KEPT=()
LINK_STOW_REPLACED=0
LINK_ANS=""
LINK_ZSHRC_BK=""
LINK_GITCONFIG_BK=""

# /Users/me/.zshrc -> ~/.zshrc, for display.
tilde() {
  case "$1" in
    "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# Open the terminal on fd 9 for answers. The rest of the script may be reading a
# pipe (curl | bash), so we never read answers from stdin.
link_begin() {
  LINK_INTERACTIVE=0
  dry && return 0
  [[ "$LINK_POLICY" == ask ]] || return 0
  if { : <"$LINK_TTY"; } 2>/dev/null; then
    exec 9<"$LINK_TTY"
    LINK_INTERACTIVE=1
  fi
  return 0
}

# "a file", "a directory", or what a symlink points at.
describe_dst() {
  local dst=$1 t
  if [[ -L "$dst" ]]; then
    t="$(readlink "$dst")"
    if [[ ! -e "$dst" ]]; then
      printf 'a broken symlink to %s' "$t"
    elif [[ "$t" != /* ]]; then
      printf 'a symlink to %s, a relative link of the kind GNU Stow makes' "$t"
    else
      printf 'a symlink to %s' "$(tilde "$t")"
    fi
  elif [[ -d "$dst" ]]; then
    printf 'a directory'
  else
    printf 'a file'
  fi
}

is_relative_link() { [[ -L "$1" && "$(readlink "$1")" != /* ]]; }

# Move $1 into $BACKUP_DIR and print where it went. Prints nothing else, so it is
# safe inside $( ).
backup_dst() {
  local dst=$1 dest t abs
  dest="$BACKUP_DIR/${dst#"$HOME"/}"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dst" ]]; then
    # A relative link (stow) would dangle from the backup dir, so keep an
    # absolute link to the same file. Only the link moves; its target is untouched.
    t="$(readlink "$dst")"
    abs="$t"
    if [[ "$t" != /* ]]; then
      abs="$(cd "$(dirname "$dst")" && cd "$(dirname "$t")" 2>/dev/null && printf '%s/%s' "$(pwd -P)" "$(basename "$t")")" || abs="$t"
    fi
    ln -s "$abs" "$dest"
    rm "$dst"
  else
    mv "$dst" "$dest"
  fi
  printf '%s' "$dest"
}

# ", it was a link to X" for symlinks, so the log says how to put one back.
link_note() { [[ -L "$1" ]] && printf '; it was a link to %s' "$(readlink "$1")"; return 0; }

# Unified diff of yours vs the repo's, through a pager if one is handy.
show_diff() {
  local src=$1 dst=$2
  echo
  {
    if diff -ru "$dst" "$src"; then echo "(no differences)"; fi
  } 2>&1 | { if [[ -t 1 ]] && command -v less >/dev/null 2>&1; then less -FRX; else cat; fi; }
  echo "  ('-' lines are yours, '+' lines are this repo's)"
}

# Read one answer (first character of a line) into LINK_ANS. EOF means keep.
link_ask() {
  local ans
  printf '%s' "$1"
  if ! IFS= read -r -u 9 ans; then LINK_ANS=k; echo; return 0; fi
  LINK_ANS="${ans:0:1}"
}

# Hand-merge in a diff editor. Left pane = a copy of your file (this becomes the
# result); right pane = the repo's. Returns 0 only if a changed file was
# installed, after backing up the original.
merge_files() {
  local src=$1 dst=$2 tool="${MERGE_TOOL:-vimdiff}" tmp bk note
  if ! command -v "${tool%% *}" >/dev/null 2>&1; then
    warn "'${tool%% *}' not found. Set MERGE_TOOL to a diff editor, e.g. MERGE_TOOL='code --wait --diff'."
    return 1
  fi
  tmp="$(mktemp "${TMPDIR:-/tmp}/dotmerge.XXXXXX")" || return 1
  cp "$dst" "$tmp"
  echo
  say "Merging: LEFT is your $(tilde "$dst") (edit it), RIGHT is the repo's. In vimdiff, :wqa saves and quits."
  # shellcheck disable=SC2086  # MERGE_TOOL may carry arguments
  $tool "$tmp" "$src" <&9 || true
  if cmp -s "$tmp" "$dst"; then
    warn "No changes were saved, so nothing was merged."
    rm -f "$tmp"
    return 1
  fi
  note="$(link_note "$dst")"
  bk="$(backup_dst "$dst")"
  cp -p "$bk" "$dst" && cat "$tmp" > "$dst"   # cp -p keeps the original's mode
  rm -f "$tmp"
  LINK_LOG+=("merged   $(tilde "$dst") (original in $(tilde "$bk")$note; now a plain file, not linked to the repo)")
  return 0
}

# link_dotfile SRC DST
link_dotfile() {
  local src=$1 dst=$2 shown desc choice="" bk note was_rel=0
  shown="$(tilde "$dst")"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    LINK_LOG+=("ok       $shown (already linked)")
    return 0
  fi

  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    if dry; then LINK_LOG+=("link     $shown (new)"); return 0; fi
    ln -s "$src" "$dst"
    LINK_LOG+=("linked   $shown")
    return 0
  fi

  # A plain copy identical to the repo's loses nothing when replaced.
  if [[ ! -L "$dst" ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
    if dry; then LINK_LOG+=("link     $shown (identical copy, no questions)"); return 0; fi
    bk="$(backup_dst "$dst")"
    ln -s "$src" "$dst"
    LINK_LOG+=("linked   $shown (identical to the repo's; old copy in $(tilde "$bk"))")
    return 0
  fi

  desc="$(describe_dst "$dst")"
  if dry; then
    LINK_LOG+=("conflict $shown is $desc; you would be asked: keep, new, merge or diff")
    return 0
  fi

  if is_relative_link "$dst"; then was_rel=1; fi
  choice="$LINK_ALL"
  if [[ -z "$choice" ]]; then
    case "$LINK_POLICY" in keep|new) choice="$LINK_POLICY" ;; esac
  fi
  if [[ -z "$choice" && "$LINK_INTERACTIVE" != 1 ]]; then
    choice=keep
    warn "No terminal to ask on; keeping your $shown. Re-run in a terminal, or set DOTFILES_LINK=new."
  fi

  while [[ -z "$choice" ]]; do
    printf '\n  %s already exists: %s.\n' "$shown" "$desc"
    echo "  [k]eep yours   [n]ew: use this repo's (yours is backed up)   [m]erge   [d]iff"
    echo "  (K or N: give the same answer to every remaining conflict)"
    [[ "$dst" != "$HOME/.zshrc" ]] || echo "  Tip: personal zsh config (aliases, exports, source lines) goes in ~/.zshrc.local, which the repo's .zshrc loads last."
    [[ "$dst" != "$HOME/.gitconfig" ]] || echo "  Tip: personal git settings go in ~/.gitconfig.local, which the repo's .gitconfig includes."
    link_ask '  ? '
    case "$LINK_ANS" in
      k) choice=keep ;;
      K) choice=keep; LINK_ALL=keep ;;
      n) choice=new ;;
      N) choice=new; LINK_ALL=new ;;
      d|D) show_diff "$src" "$dst" ;;
      m|M)
        if [[ ! -f "$dst" || ! -f "$src" ]]; then
          warn "Merge works on single files. Use [d]iff and merge by hand, or keep/new."
        elif merge_files "$src" "$dst"; then
          choice=merged
        fi
        ;;
      *) echo "  Please answer k, n, m or d." ;;
    esac
  done

  case "$choice" in
    keep)
      LINK_KEPT+=("$dst")
      LINK_LOG+=("kept     $shown (yours)")
      ;;
    new)
      note="$(link_note "$dst")"
      bk="$(backup_dst "$dst")"
      ln -s "$src" "$dst"
      LINK_LOG+=("linked   $shown (yours moved to $(tilde "$bk")$note)")
      if [[ "$dst" == "$HOME/.zshrc" ]]; then LINK_ZSHRC_BK="$bk"; fi
      if [[ "$dst" == "$HOME/.gitconfig" ]]; then LINK_GITCONFIG_BK="$bk"; fi
      ;;
  esac
  if [[ "$choice" != keep && "$was_rel" == 1 ]]; then LINK_STOW_REPLACED=1; fi
  return 0
}

# What happened, and what to do about files we left alone.
link_summary() {
  local l k
  echo
  if dry; then say "Dotfiles (dry run, nothing changed):"; else say "Dotfiles:"; fi
  for l in "${LINK_LOG[@]}"; do echo "  $l"; done

  if [[ -d "$BACKUP_DIR" ]]; then
    echo
    say "Originals you replaced or merged are in $(tilde "$BACKUP_DIR"). Move one back to restore it."
  fi
  if [[ -n "$LINK_ZSHRC_BK" ]]; then
    echo
    say "Your old ~/.zshrc is saved at $(tilde "$LINK_ZSHRC_BK"). Move anything personal (aliases, exports, source lines) into ~/.zshrc.local; the new .zshrc loads it last."
  fi
  if [[ -n "$LINK_GITCONFIG_BK" ]]; then
    echo
    say "Your old ~/.gitconfig is saved at $(tilde "$LINK_GITCONFIG_BK"). Move personal settings into ~/.gitconfig.local; the new .gitconfig includes it."
  fi
  if [[ "$LINK_STOW_REPLACED" == 1 ]]; then
    echo
    warn "Some replaced files were stow-managed symlinks. Your stow directory is untouched, but stow will report a conflict for them when you restow; unstow those files first."
  fi
  if (( ${#LINK_KEPT[@]} )); then
    for k in "${LINK_KEPT[@]}"; do
      [[ "$k" == "$HOME/.zshrc" ]] || continue
      echo
      say "You kept your ~/.zshrc, so mise and the oh-my-zsh plugins you chose are not loaded. To use them, add to it:"
      cat <<'EOF'

    # after any `brew shellenv` line, so mise's ruby/node win over Homebrew's
    eval "$(mise activate zsh)"
    export ZSH="$HOME/.oh-my-zsh"
    plugins=(git)
    [ -r ~/.config/dotfiles/zsh-plugins.zsh ] && source ~/.config/dotfiles/zsh-plugins.zsh
    source "$ZSH/oh-my-zsh.sh"

EOF
    done
  fi
  return 0
}
