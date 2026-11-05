# shellcheck shell=bash
# fonts topic: which Nerd Fonts to install. Sourced by script/ask.

ask_fonts() {
  # --- Nerd Fonts --------------------------------------------------------------
  # Terminal fonts with icons (needed by LazyVim, powerline-style prompts). The
  # list comes from Homebrew so it always matches what is installable.
  # Short names map to casks: fira-code -> font-fira-code-nerd-font.
  if [[ -z "${FONTS:-}" ]]; then
    FONT_DEFAULTS=" fira-code dejavu-sans-mono "
    FONT_LIGATURE=" fira-code jetbrains-mono caskaydia-cove monaspace victor-mono iosevka hasklug "
    found="$(brew search --casks '/^font-.+-nerd-font$/' 2>/dev/null | sed 's#.*/##' | grep -E '^font-.+-nerd-font$' | sort -u || true)"
    [[ -n "$found" ]] || found="$(printf 'font-%s-nerd-font\n' fira-code dejavu-sans-mono jetbrains-mono hack meslo-lg caskaydia-cove monaspace)"
    # Defaults first so they are the visible page; everything else is behind 'm'.
    default_re='^font-(fira-code|dejavu-sans-mono)-nerd-font$'
    found="$({ echo "$found" | grep -E "$default_re" || true; echo "$found" | grep -vE "$default_re" || true; } | grep -v '^$')"
    ITEM_NAMES=(); ITEM_DESCS=(); ITEM_ON=(); ITEM_VERS=(); ITEM_CHK=()
    while IFS= read -r cask; do
      short="${cask#font-}"; short="${short%-nerd-font}"
      ITEM_NAMES+=("$short")
      desc=""; [[ "$FONT_LIGATURE" == *" $short "* ]] && desc="ligatures"
      [[ "$short" == dejavu-sans-mono ]] && desc="no ligatures; classic"
      ITEM_DESCS+=("$desc")
      if [[ "$FONT_DEFAULTS" == *" $short "* ]]; then ITEM_ON+=(1); else ITEM_ON+=(0); fi
    done <<< "$found"
    if can_prompt; then
      PICK_INITIAL=0
      for i in "${!ITEM_ON[@]}"; do [[ "${ITEM_ON[$i]}" == 1 ]] && PICK_INITIAL=$((PICK_INITIAL + 1)); done
      PICK_NOTE="  Samples: https://www.nerdfonts.com/font-downloads  (ligature support depends on your terminal)"
      pick_items "Nerd Fonts (installed via Homebrew; ${#ITEM_NAMES[@]} available):" 0 2
      PICK_INITIAL=0; PICK_NOTE=""
      FONTS="$PICKED"
    else
      FONTS=""
      for i in "${!ITEM_NAMES[@]}"; do [[ "${ITEM_ON[$i]}" == 1 ]] && FONTS="$FONTS ${ITEM_NAMES[$i]}"; done
      FONTS="${FONTS# }"
    fi
    FONTS="${FONTS:-none}"
  elif [[ "$FONTS" != none && " $SAVED_VARS " != *" FONTS "* ]]; then
    for f in $FONTS; do
      valid_font "$f" || die "FONTS: no Homebrew cask font-$f-nerd-font"
    done
  fi
  [[ "$FONTS" == none ]] && FONTS=""
  return 0
}
