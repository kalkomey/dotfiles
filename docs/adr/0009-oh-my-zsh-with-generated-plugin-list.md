# 0009. oh-my-zsh with a generated plugin list; our aliases win

- Status: Accepted
- Date: 2026-10-14

## Context

Every engineer is on a Mac and so most likely on zsh. Plugins for git, AWS, Docker, Terraform, Rails and so on
already exist in oh-my-zsh, so we would rather use them than maintain our own completions and aliases.

Two constraints shape how:

- After `script/bootstrap`, `~/.zshrc` is a **symlink into this repo** (`zsh/zshrc.symlink`). An installer that appended
  to `~/.zshrc` would be editing a tracked file.
- oh-my-zsh's plugins define aliases (`gc`, `gd`, `gca`, ...) that collide with ours, and ours matter: `gc` signs
  commits with `-S`.

## Decision

- `zsh/install.sh` installs oh-my-zsh unattended (without replacing `.zshrc`) plus the external plugins
  `zsh-autosuggestions` and `zsh-syntax-highlighting` if selected.
- The chosen plugin list is written to `~/.config/dotfiles/zsh-plugins.zsh`, outside the repo. `zshrc.symlink` loads
  it (defaulting to `plugins=(git)`) and then sources oh-my-zsh.
- mise is activated **before** oh-my-zsh, so tools it provides (fzf, direnv) exist when their plugins load.
- Homebrew's `shellenv` is evaluated just before mise, so mise's tool directories end up ahead of Homebrew's on `PATH`
  and mise's ruby and node win over any that Homebrew installed as a dependency.
- `~/.zshrc` only runs in interactive shells, so `zsh/install.sh` also appends a delimited block to `~/.zprofile`
  (created if missing, written once, never through a symlink) that evaluates `brew shellenv` and then
  `mise activate zsh --shims`. Login shells, scripts, git hooks and IDE tasks get mise's runtimes through the shims;
  interactive shells get them through `mise activate`. Both follow the same mise config, so the versions match.
  It goes in `~/.zprofile`, not `~/.zshenv`, because `/etc/zprofile` (macOS `path_helper`) reorders `PATH` after
  `.zshenv` runs and would put system tools ahead of the shims.
- After oh-my-zsh loads, `zshrc.symlink` re-sources every `aliases.zsh` so our aliases override the plugins'.
- The default plugins are `git gh aws docker docker-compose terraform ruby rails bundler npm yarn fzf direnv zoxide tmux macos`
  plus the two external ones, with `zsh-syntax-highlighting` last. Engineers choose their own in the picker
  ([0005](0005-defaults-first-pickers-with-validated-free-form-entries.md)).

- The `zoxide` plugin defines `z` and `zi`. If the engineer opts in, `zsh/install.sh` appends
  `export ZOXIDE_CMD_OVERRIDE=cd` to `~/.zshenv` (created if missing, not duplicated), which makes the plugin define
  `cd` and `cdi` instead. `~/.zshenv` is used because zsh reads it before `~/.zshrc`, and it is not a tracked file.

## Alternatives considered

- **Append a block to `~/.zshrc`**: edits the repo file through the symlink.
- **A separate managed file sourced from `~/.zshrc`**: works for standalone installs but needs a `source` line added to
  a file we do not own; reading the plugin list from `zshrc.symlink` avoids that.
- **Other frameworks (zinit, antidote, prezto)**: lighter or faster, but oh-my-zsh is the one most engineers already
  know.
- **Hand-write completions and aliases**: more maintenance for less coverage.

## Consequences

- Engineers get completions and aliases for the tools we use with little config.
- oh-my-zsh adds shell startup time.
- Re-sourcing aliases after oh-my-zsh means our definitions silently shadow plugin ones; a new alias in this repo can
  hide a plugin alias of the same name.
- Plugin choices live per machine, not in the repo.
