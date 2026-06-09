# Contributing

These dotfiles are **one shared repo the whole team tracks**. The golden rule:

> **If a change helps only you, put it in a `.local` file. If it helps the team, open a PR.**

## Local change vs. shared change

- **Just for you** → an untracked `.local` file (`~/.zshrc.local`, `~/.gitconfig.local`,
  `~/.tmux.conf.local`, `~/.vimrc.local`). These are sourced automatically and survive
  `git pull`. Never edit a tracked `*.symlink`/`*.zsh` file for a personal preference.
- **For everyone** → a branch and a PR against this repo.

## Repo conventions

Everything is organized by **topic** (one directory per area). Within a topic:

- `*.zsh` — auto-sourced into the shell. Aliases, exports, functions, completions.
- `*.symlink` — symlinked into `$HOME` without the extension when `bootstrap` runs.
- `install.sh` — run by `bin/dot` to install the topic's dependencies. **Must branch
  per-OS** (`case "$(uname)"` → Darwin / Linux) and be **idempotent** (safe to re-run).
- `bin/` — scripts here are on `$PATH`.

### Adding a new topic

1. Create the directory (e.g. `rust/`).
2. Add `*.zsh` for shell config, `*.symlink` for dotfiles, `install.sh` for dependencies.
3. If it adds a tool, **add a row to [`docs/package-matrix.md`](docs/package-matrix.md)
   in the same PR** (see below).
4. Wire `install.sh` into `bin/dot` in the right order if it should run on `dot`.

## The package matrix is the contract

[`docs/package-matrix.md`](docs/package-matrix.md) records, for every shared tool: the
capability, how it's installed on macOS, how on Ubuntu, which topic owns it, and how
closely versions must track. **A PR that adds, removes, or moves a tool must update the
matrix in the same PR.** A drift between the matrix and the installers is a bug.

Ground rules the matrix encodes:

- macOS uses **Homebrew**; Ubuntu uses **apt** → **vendor apt repo** → **official binary
  installer**, in that order of preference.
- **Homebrew-on-Linux only as an explicit exception**, when no native path exists.
- Language runtimes stay in their topic installers (chruby/ruby-install, nvm, pyenv).
- Prefer boring OS-native defaults over cross-platform cleverness.
- Installers may upgrade packages but **must not overwrite user-owned config without an
  explicit prompt**.

## Quality bar

- **shellcheck** your scripts (`shellcheck script/foo`). zsh-shebang installers can't be
  shellchecked cleanly — gate those on `zsh -n`.
- Run **`script/doctor`** after your change to confirm nothing regressed.
- **Test on both platforms** before merging anything OS-specific: macOS (Apple Silicon)
  and an **Ubuntu 24.04 VM**. The matrix promises parity; prove it.
- Keep PRs small and focused. One topic / one concern per PR.

## PR flow

```sh
cd ~/.dotfiles
git checkout -b my-change
# ... edit tracked files, update docs/package-matrix.md if needed ...
shellcheck script/...        # and/or zsh -n on zsh installers
./script/doctor              # sanity check
git commit && git push -u origin my-change
gh pr create
```

## Updating your machine

```sh
cd ~/.dotfiles && git pull && bin/dot && script/doctor
```
