# zsh only (hence not .zsh: ~/.zshrc sources it after mise is active, not with the
# topic files). Tool integrations that work the same with or without oh-my-zsh, which
# is used only for its theme: fzf, zoxide, direnv and shell completions.
# Each one runs only when its tool is on PATH, so a tool you did not install is skipped.

# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd. (A ~/.fzf.zsh from an older setup is
# sourced by ~/.zshrc already.)
if (( $+commands[fzf] )) && [[ ! -f ~/.fzf.zsh ]]; then
  source <(fzf --zsh 2>/dev/null)
fi

# zoxide: z and zi, and cd as well when ZOXIDE_CMD_OVERRIDE=cd is set (~/.zshenv).
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd "${ZOXIDE_CMD_OVERRIDE:-z}" zsh)"
fi

# direnv: load and unload .envrc files as you change directory.
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Completions. gh, docker, colima, op, rg and mise ship zsh completions that zsh/install.sh
# writes to ~/.config/dotfiles/completions (on fpath, see ~/.zshrc). The HashiCorp CLIs
# and aws complete through bash's `complete -C`, which zsh emulates with bashcompinit.
autoload -U +X bashcompinit && bashcompinit
for _t in terraform vault nomad consul; do
  (( $+commands[$_t] )) && complete -o nospace -C "${commands[$_t]}" $_t
done
(( $+commands[aws_completer] )) && complete -C "${commands[aws_completer]}" aws
unset _t
