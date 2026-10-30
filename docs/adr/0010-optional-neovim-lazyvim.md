# 0010. Optional Neovim + LazyVim alongside the existing vim setup

- Status: Accepted
- Date: 2026-10-14

## Context

Many engineers want Neovim with a ready-made configuration, but the repo's vim setup (pathogen bundles installed by
`vim/install.sh`, config in `vimrc.symlink` and `vim.symlink/`) is what existing users rely on and should not change
under them.

## Decision

Neovim + [LazyVim](https://www.lazyvim.org) is an opt-in question (default no). If chosen, the installer:

- adds `neovim`, `fd` and `lazygit` (via mise; `ripgrep` and `fzf` are already default tools),
- clones the LazyVim starter into `~/.config/nvim` and removes its `.git` so the config is the engineer's own,
- runs a headless plugin sync so the first launch is fast,
- leaves `~/.config/nvim` alone if it already exists.

`vim` still uses the existing config, `$EDITOR` is unchanged, and Neovim is started with `nvim`. LazyVim wants a Nerd
Font; the font picker ([0011](0011-nerd-fonts-chosen-from-homebrew.md)) covers that, and the installer warns if Neovim is
chosen with no font.

## Alternatives considered

- **Install it for everyone**: changes the default editing experience for people who did not ask.
- **Replace vim config with Neovim config**: forces a migration on existing users.
- **Hand-maintained Neovim config in the repo**: more to maintain than a well-supported distribution.
- **Other distributions (AstroNvim, NvChad, kickstart)**: LazyVim was the one asked for.

## Consequences

- Engineers can opt in without disturbing anyone else.
- We depend on LazyVim's starter and its Neovim version requirements; the starter is cloned at install time, so what
  people get changes over time.
- Making `nvim` the default editor or aliasing `vim` to it is deliberately left for a later decision.
