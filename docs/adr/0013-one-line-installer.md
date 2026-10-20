# 0013. One-line installer (`setup.sh`) that clones to `~/.dotfiles`

- Status: Accepted
- Date: 2026-10-20

## Context

Setting up used to mean cloning the repo, `cd`-ing into it and running `script/bootstrap`. We want new engineers to run
one command. The repo is public, so an unauthenticated `curl` works. Two things make piping a script into bash fragile:

- bash reads the script from stdin as it runs. Any child process that also reads stdin (our `read` prompts) would eat the
  rest of the script instead of waiting for an answer.
- A download cut off partway can leave bash executing half a script.

`bin/dot`, the Brewfile step and `zshrc.symlink` all assume the repo lives at `~/.dotfiles`.

## Decision

A small `setup.sh` at the repo root, fetched from `raw.githubusercontent.com`:

```sh
curl -fsSL https://raw.githubusercontent.com/kalkomey/dotfiles/master/setup.sh | bash
```

- It checks for macOS, installs the Xcode Command Line Tools if missing (that is where git comes from), then clones into
  `~/.dotfiles`.
- It runs `script/bootstrap` with `/dev/tty` as stdin, so every question (git identity, conflict prompts, pickers) reads
  from the terminal and not the pipe. With no terminal it runs with stdin from `/dev/null` and the usual unattended
  behavior: defaults, and existing files kept ([0012](0012-never-overwrite-existing-dotfiles.md)).
- All the logic is inside `main()`, called on the last line, so a truncated download runs nothing.
- Arguments pass through: `... | bash -s -- --dry-run`.
- An existing `~/.dotfiles` is only touched when that cannot hurt: `origin` must be this repo, there must be no
  uncommitted changes, it must already be on the branch being installed, and the update is `--ff-only`. Otherwise it stops and
  says why. `DOTFILES_SKIP_UPDATE=1` uses the directory exactly as it is (for working on the repo itself).
- `DOTFILES_BRANCH` and `DOTFILES_REPO` override the branch and URL, for trying a branch before it is merged.
- The file is `setup.sh`, not `install.sh`, because `script/install` runs every file named `install.sh` it finds.

## Alternatives considered

- **Download a tarball instead of cloning**: needs no git, but leaves a directory that cannot be updated with `git pull`,
  and `bin/dot` is meant to be re-run to stay current.
- **Install to a different directory**: the paths in `bin/dot`, the Brewfile step and `zshrc.symlink` would all need to
  change, and existing checkouts are already at `~/.dotfiles`.
- **A short URL on a Kalkomey domain**: nicer to type, but it is one more thing to host. Easy to add later, since it would
  only redirect to the raw URL.
- **Make people read and verify the script first**: we document that as an option, but the default stays one line.

## Consequences

- One command from a fresh Mac, and the same command updates an existing clean checkout and re-runs.
- Running a script from the network is a trust decision; people who want to inspect it can download it first (the README
  shows how), and the repo is the single source.
- The installer fetches `master`. Until a change is merged there, people trying a branch must set `DOTFILES_BRANCH` and the
  branch must be pushed.
- Developers with `~/.dotfiles` on a feature branch or with local changes are stopped, not switched.
