# 0017. The starship prompt is an opt-in question, installed with mise

- Status: Accepted
- Date: 2026-11-02

## Context

Some engineers want the starship prompt instead of the oh-my-zsh `robbyrussell` theme. A prompt is a personal preference, so
it should not change for everyone. Starship is available from both Homebrew and mise, and we are putting as much as
possible in mise (ADR 0002).

## Decision

`script/ask` asks "Use the starship prompt?" (default no, `STARSHIP=1|0` to skip the question). On yes, `derive_answers`
adds `starship` to the mise tools, and `starship/install.sh` writes `~/.config/dotfiles/starship.zsh` (a guarded
`eval "$(starship init zsh)"`) and copies `starship/starship.toml.example` to `~/.config/starship.toml` only if that file
does not exist. `~/.zshrc` sources the generated file after oh-my-zsh, so starship's prompt replaces the theme. Answering
no later removes the generated file and leaves `starship.toml` alone.

## Alternatives considered

- **Homebrew's starship**: works, but splits tool management between two systems.
- **On for everyone**: a prompt is personal; the default stays as it was.
- **Edit `~/.zshrc` directly**: it may be someone's own file (or a stow symlink). A generated file in
  `~/.config/dotfiles` that the repo's `.zshrc` sources follows how the oh-my-zsh plugin list already works.
- **Starter config with Nerd Font icons**: breaks in terminals not set to a Nerd Font. The example uses plain-text
  symbols and says how to switch to the nerd-font preset.

## Consequences

- People who keep their own `~/.zshrc` are told the line to add, like the oh-my-zsh lines.
- The starter config is copied once; later changes to the example never reach existing copies.
- Starship and the oh-my-zsh theme can both be set; starship wins because it initializes last.
