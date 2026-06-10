# Kalkomey dotfiles

A **ready-to-work Kalkomey developer machine** on macOS (Apple Silicon) and Ubuntu
24.04. One clone, one bootstrap, and you have the shell, tools, runtimes, and config the
team uses. Based on [Zach Holman](https://github.com/holman)'s
[dotfiles](https://github.com/holman/dotfiles) and Hashrocket's
[dotmatrix](https://github.com/hashrocket/dotmatrix), adapted into a shared, centrally
managed repo.

This is **one shared repo everyone tracks** — not a personal fork. Tweaks that are just
for you go in untracked `.local` files; changes for the whole team go through a PR. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## Install

```sh
git clone git@github.com:kalkomey/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

`bootstrap` sets up your git identity and SSH key, symlinks the config files into your
home directory, and then runs `bin/dot` to install everything.

## The three commands

| Command | What it does |
|---|---|
| `script/bootstrap` | One-time setup: git identity, SSH key, symlinks, then `dot`. |
| `bin/dot` | Install/update everything. **Run it periodically** to stay current. OS-aware: Homebrew on macOS, apt/vendor repos on Ubuntu. |
| `script/doctor` | Report what's installed vs. missing. **Never installs or fixes** — just tells you if your machine is ready. |

## How it works

Everything is organized by **topic** — one directory per area (`git/`, `tmux/`, `ruby/`,
`infra/`, …). Within a topic:

- `*.zsh` files are **auto-sourced** into your shell (aliases, config, functions).
- `*.symlink` files are **symlinked** into `$HOME` without the extension
  (`git/gitconfig.symlink` → `~/.gitconfig`).
- `install.sh` is run by `dot` to install that topic's dependencies; it branches per-OS.
- `bin/` is on your `$PATH`, so its scripts are available as commands.

Which tool comes from where (Homebrew vs apt vs a vendor repo vs a binary installer) is
documented in **[docs/package-matrix.md](docs/package-matrix.md)** — the shared contract.
Parity is by capability, not by package manager: macOS uses Homebrew; Ubuntu uses
apt / vendor apt repos / official installers. A few capabilities are macOS-only (iOS), and
some legacy stacks are deliberately out of scope — all recorded in the matrix.

Cross-OS niceties are handled for you: clipboard access (`pbcopy`/`pbpaste`, the `pubkey`
helper, tmux copy) works the same via `system/clipboard.zsh` (native on macOS,
`wl-clipboard` on Wayland, `xclip` on X11).

## Where your personal changes go

**If a change helps only you, put it in a `.local` file. If it helps the team, open a
PR.** The `.local` files are untracked and sourced automatically, so they survive
`git pull`:

| File | For |
|---|---|
| `~/.zshrc.local` | Personal shell exports, aliases, paths, prompt tweaks |
| `~/.gitconfig.local` | Your git identity and personal git preferences |
| `~/.tmux.conf.local` | Personal tmux overrides |
| `~/.vimrc.local` | Personal vim overrides |
| `.mux` (per project) | Project tmux session layout |

Don't edit the tracked `*.symlink`/`*.zsh` files for personal preferences — that's what
`.local` is for. Editing tracked files is for changes you intend to PR for everyone.

## Staying current

```sh
cd ~/.dotfiles && git pull && bin/dot && script/doctor
```

## Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)** — how to make a local change vs. a shared
change, the topic conventions, the package-matrix contract, and the PR flow.

## Linux desktop (Phase 2)

A Hyprland/Wayland desktop layer for Ubuntu is planned but **not yet built** — see
**[PHASE2-DESKTOP.md](PHASE2-DESKTOP.md)**.

## Thanks

Forked from [Zach Holman](http://github.com/holman)'s
[dotfiles](http://github.com/holman/dotfiles); much also stems from Hashrocket's Dotmatrix
and, by extension, Ryan Bates' original dotfiles.
