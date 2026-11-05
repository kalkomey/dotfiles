# 0019. Tool integrations do not depend on oh-my-zsh; oh-my-zsh is theme-only

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

- oh-my-zsh is used only for its theme and loads no plugins (`plugins=()`).
- `zsh/integrations.sh`, sourced by `~/.zshrc`, sets up fzf, zoxide (honoring `ZOXIDE_CMD_OVERRIDE`), direnv and
  completions, each only when its tool is on PATH. `zsh/install.sh` writes zsh completion scripts for gh, docker, colima,
  op, rg and mise to `~/.config/dotfiles/completions` (on `fpath` before `compinit`); the HashiCorp CLIs and aws use
  bashcompinit.
- zsh-autosuggestions and zsh-syntax-highlighting are an optional question, installed from Homebrew and sourced last by
  `zsh/typing.sh`.
- The oh-my-zsh plugin picker, its generated plugin list and the zoxide plugin gating are gone. The zoxide `cd` question is
  asked whenever zoxide is among the tools.

## Alternatives considered

- **Keep plugins and add fallbacks for the other choices**: two code paths for every tool, and double initialization when both
  load. One path that always runs is simpler to reason about.
- **Generate each tool's init into a file at install time**: faster startup, but stale after a tool upgrade; the completion
  files are the exception because they are large and slow to produce.

## Consequences

- Everything in the list above works for all four choices. Plugin-provided aliases (rails, bundler, git) are no longer
  loaded from oh-my-zsh; the repo's own aliases cover git and ruby.
- Saved `ZSH_PLUGINS` answers are ignored. The old `~/.config/dotfiles/zsh-plugins.zsh` is removed and replaced by `ohmyzsh.zsh`.
- Completions refresh when `zsh/install.sh` runs (every `dot` run).
- People who keep their own `~/.zshrc` get the lines to add, including the two `source` lines.
