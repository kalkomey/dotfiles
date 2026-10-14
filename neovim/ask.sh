# shellcheck shell=bash
# neovim topic: opt-in Neovim + LazyVim. Sourced by script/ask (after fonts,
# since LazyVim wants a Nerd Font).

ask_neovim() {
  # It lives in ~/.config/nvim next to the existing vim setup.
  if [[ -z "${NEOVIM:-}" ]]; then
    NEOVIM=0
    if can_prompt; then
      echo
      read -r -p "Install Neovim + LazyVim (adds neovim, fd and lazygit; LazyVim wants a Nerd Font)? [y/N] " ans </dev/tty || ans=""
      [[ "$ans" =~ ^[Yy] ]] && NEOVIM=1
    fi
  fi
  if [[ "$NEOVIM" == 1 && ( -z "${FONTS:-}" || "$FONTS" == none ) ]]; then
    warn "LazyVim shows icons via a Nerd Font and you picked none; install one or use a terminal that bundles it."
  fi
  return 0
}
