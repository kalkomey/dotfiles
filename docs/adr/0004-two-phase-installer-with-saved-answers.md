# 0004. Ask-then-install, split by topic, with saved answers and `--dry-run`

- Status: Accepted
- Date: 2026-10-14

## Context

`script/bootstrap` runs `bin/dot`, which runs a series of slow installers (Homebrew bundle,
Docker, language builds). If each installer asked its own questions, an engineer would answer one,
wait several minutes, answer the next, and so on, and a typo in an answer would surface only after
a long compile. `bin/dot` is also meant to be re-run periodically, so asking every time would be
an annoyance.

The repo organizes everything by topic directory (`git/`, `ruby/`, `tmux/`, ...), each with its own
`install.sh`, and we want that to hold for the new pieces too: a single script that installs mise,
fonts, Neovim and oh-my-zsh would bury unrelated things together and could not be re-run piece by piece
(for example, to add a font later).

macOS ships bash 3.2, and engineers run this on a fresh machine, so the installer cannot rely on a
newer bash.

## Decision

**Ask first, install later.** `script/ask` installs the prerequisites (Xcode Command Line Tools,
Homebrew, mise), then asks every question and saves the answers to `~/.config/dotfiles/install-choices`.
`bin/dot` runs it first thing; the slow installers that follow read the saved answers and run unattended.
Saved answers are reused silently on later runs; `RECONFIGURE=1` asks again; environment variables
(`MISE_LANGUAGES`, `MISE_TOOLS`, `FONTS`, `NEOVIM`, `ZSH_PLUGINS`, `ZOXIDE_CD`) override both and skip the matching question.

**One topic per directory.** Each of `mise/`, `fonts/`, `neovim/` and `zsh/` owns its questions
(`ask.sh`, sourced by `script/ask`) and its installer (`install.sh`). Each `install.sh` runs on its own: it
loads the saved answers, running `script/ask` first if there are none. Code shared by all of them (the
pickers, validation, the answers file, prerequisite checks) lives in `script/lib/common.sh`. `bin/dot` calls
the installers in order: mise, fonts, Neovim, oh-my-zsh.

**`script/ask --dry-run`** (or `DRY_RUN=1`) runs the questions, prints the resulting choices, and stops. It
installs nothing and saves nothing, and degrades gracefully if Homebrew or mise are not yet installed.
Anything implied by the answers (Erlang for Elixir) is computed by a function shared with the real install, so
the preview matches what will happen. The topic installers refuse `--dry-run`.

The scripts stick to bash 3.2 features (parallel arrays instead of associative arrays, no namerefs).

## Alternatives considered

- **Ask inside each topic installer**: scattered questions, and validation problems surfaced late.
- **One big installer file** (what we first built): simple to ship, but it mixes four topics and cannot be
  re-run per topic.
- **A config file the user edits by hand**: more flexible, but a worse first-run experience than
  being asked.
- **Prompt on every run**: tedious for a script intended to be re-run.
- **Install a newer bash first**: adds a prerequisite to the prerequisite step.

## Consequences

- All questions happen before any slow work, and the rest can run unattended.
- The answers file lives outside the repo, so personal choices are never committed.
- Prerequisites install during `ask`, so a plain `script/ask` still changes the machine; only `--dry-run` is
  side-effect free.
- Adding a topic means adding an `ask.sh` and `install.sh` and wiring both into `script/ask` and `bin/dot`.
- Neovim's installer depends on mise (it installs neovim, fd and lazygit through it), so the order in
  `bin/dot` matters. It runs `nvim` through `mise exec`, because `mise activate` only applies in interactive
  shells.
- `script/install` (which runs every `install.sh` it finds) will now also run these topic installers; each works
  standalone, so that is harmless.
- Constraints of bash 3.2 shape the code (parallel arrays, `eval` for array copies).
