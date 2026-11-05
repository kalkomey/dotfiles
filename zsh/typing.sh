# zsh only. zsh-autosuggestions (fish-style suggestions as you type) and
# zsh-syntax-highlighting (colors valid and invalid commands), from Homebrew; zsh/install.sh
# installs them if you chose them. ~/.zshrc sources this last: syntax-highlighting has to
# come after everything that binds keys or widgets. Skipped if they are not installed.
for _p in zsh-autosuggestions zsh-syntax-highlighting; do
  for _d in "${HOMEBREW_PREFIX:-/opt/homebrew}" /usr/local; do
    if [[ -r "$_d/share/$_p/$_p.zsh" ]]; then
      source "$_d/share/$_p/$_p.zsh"
      break
    fi
  done
done
unset _p _d
