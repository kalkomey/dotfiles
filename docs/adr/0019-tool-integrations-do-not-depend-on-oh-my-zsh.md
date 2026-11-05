# 0019. Tool integrations do not depend on oh-my-zsh; its plugins are optional

- Status: Accepted
- Date: 2026-11-05
- Supersedes: [0009](0009-oh-my-zsh-with-generated-plugin-list.md)

## Context

ADR 0009 had oh-my-zsh load a chosen list of plugins, and several things people rely on came only from those plugins:
fzf's Ctrl-R, `zoxide init`, the direnv hook, tool completions. Once oh-my-zsh and starship became choices (ADR 0017),
picking "starship only" or "neither" silently turned all of that off: Ctrl-R fell back to zsh's `bck-i-search`, zoxide and
`cd` stopped working, and direnv stopped loading. Installing a prompt should not change what the shell can do.

## Decision

Whatever is chosen (oh-my-zsh, starship, both or neither), the shell behaves the same:

- oh-my-zsh keeps an optional plugin picker (asked only if oh-my-zsh is installed). Choosing none uses oh-my-zsh for its
  theme only, and plugins can be added later. The picker no longer lists fzf, zoxide, direnv, zsh-autosuggestions or
  zsh-syntax-highlighting, which are set up below; older saved lists have those names dropped so nothing loads twice.
- `zsh/integrations.sh`, sourced by `~/.zshrc`, sets up fzf, zoxide (honoring `ZOXIDE_CMD_OVERRIDE`), direnv and
  completions, each only when its tool is on PATH. `zsh/install.sh` writes zsh completion scripts for gh, docker, colima,
  op, rg and mise to `~/.config/dotfiles/completions` (on `fpath` before `compinit`); the HashiCorp CLIs and aws use
  bashcompinit.
- zsh-autosuggestions and zsh-syntax-highlighting are an optional question, installed from Homebrew and sourced last by
  `zsh/typing.sh`.
- The zoxide plugin gating is gone. The zoxide `cd` question is asked whenever zoxide is among the tools.

## Alternatives considered

- **Keep plugins and add fallbacks for the other choices**: two code paths for every tool, and double initialization when both
  load. One path that always runs is simpler to reason about.
- **Generate each tool's init into a file at install time**: faster startup, but stale after a tool upgrade; the completion
  files are the exception because they are large and slow to produce.

## Consequences

- Everything in the list above works for all four choices, with or without plugins.
- The generated plugin list moves from `~/.config/dotfiles/zsh-plugins.zsh` to `ohmyzsh.zsh`; the old file is removed.
- Completions refresh when `zsh/install.sh` runs (every `dot` run).
- People who keep their own `~/.zshrc` get the lines to add, including the two `source` lines.
