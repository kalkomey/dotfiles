# Cross-platform clipboard abstraction.
# vi:filetype=sh:
#
# dot_clipboard_copy reads stdin onto the system clipboard; dot_clipboard_paste
# writes the clipboard to stdout. Backends, in order: macOS native pbcopy/pbpaste,
# Wayland (wl-clipboard), X11 (xclip, then xsel). With no backend, copy echoes to
# stdout with a warning and paste fails clearly rather than silently doing nothing.
#
# On platforms without a native pbcopy/pbpaste (i.e. Linux) we also expose thin
# pbcopy/pbpaste shims so scripts and aliases can use those names everywhere.
# The macOS branch uses `command pbcopy` to call the real binary, never the shim,
# so the shims can't recurse back into these functions.

dot_clipboard_copy() {
  if [[ "$OSTYPE" == darwin* ]]; then
    command pbcopy
  elif [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif [[ -n "$DISPLAY" ]] && command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif [[ -n "$DISPLAY" ]] && command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "dot_clipboard_copy: no clipboard backend (install wl-clipboard or xclip); echoing to stdout" >&2
    cat
  fi
}

dot_clipboard_paste() {
  if [[ "$OSTYPE" == darwin* ]]; then
    command pbpaste
  elif [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-paste >/dev/null 2>&1; then
    wl-paste --no-newline
  elif [[ -n "$DISPLAY" ]] && command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -o
  elif [[ -n "$DISPLAY" ]] && command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
  else
    echo "dot_clipboard_paste: no clipboard backend (install wl-clipboard or xclip)" >&2
    return 1
  fi
}

# Expose pbcopy/pbpaste names where the OS doesn't provide them natively.
command -v pbcopy  >/dev/null 2>&1 || pbcopy()  { dot_clipboard_copy }
command -v pbpaste >/dev/null 2>&1 || pbpaste() { dot_clipboard_paste }
