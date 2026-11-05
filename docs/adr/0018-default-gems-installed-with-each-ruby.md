# 0018. Public default gems with every Ruby; private gems from a separate installer

- Status: Accepted
- Date: 2026-11-02

## Context

mise installs Ruby on demand (ADR 0002, ADR 0003). A fresh Ruby has only the gems that ship
with it, so each engineer installs the same few gems by hand after every Ruby install.

The mise Ruby plugin reads `~/.default-gems` (one gem per line) and installs those gems right
after it installs a Ruby version. That fits public gems. It does not fit `aios-claude`: it comes
from Kalkomey's private Gemfury server, so installing it needs
`--source "https://$BUNDLE_GEM__FURY__IO@gem.fury.io/kalkomey/"`, and `aios-claude` pulls in
`aios`. A line in a tracked file cannot carry that token, and `~/.default-gems` has no way to
read an environment variable.

## Decision

We will split the gems by where they come from:

- **`ruby/default-gems.symlink`** lists the public gems, `bundler` and `rails`. The installer
  links it to `~/.default-gems` like every other `*.symlink` file. `script/bootstrap` links
  dotfiles before `bin/dot` runs `mise/install.sh`, so the file is in place before the first
  Ruby is installed on a new machine.
- **`ruby/install.sh`** installs `aios-claude` (and `aios` as its dependency) from Gemfury.
  `bin/dot` runs it right after `mise/install.sh`. It reads the token from
  `BUNDLE_GEM__FURY__IO` in the environment, where `~/.zshrc.local` already sets it. The value
  is either the token or a 1Password reference (`op://Developers/AIOS Operator Keys/Gem Fury Read-only`),
  which the script reads with the 1Password CLI (`op`). It captures the output so the token
  never reaches the terminal, and masks it if it has to print an error.

`ruby/install.sh` never fails the install. It skips with a note when mise or Ruby is missing or
the token is not set, or a 1Password reference cannot be read (no `op`, or 1Password is locked), and it does nothing when `aios-claude` is already installed. After you add
the token, run `bash ~/.dotfiles/ruby/install.sh`.

## Alternatives considered

- **Put all four gems in `~/.default-gems`**: the private source and token cannot be expressed
  there, and the token must not be in a tracked file.
- **Write the token into `~/.default-gems` or `~/.gemrc` at install time**: leaves a secret in
  another file that is easy to commit or copy by accident.
- **A Gemfile or `bundle config` for the private gems**: these are tools, not application
  dependencies, so a Gemfile is the wrong place for them.
- **No automation**: every engineer repeats the `gem install` for each Ruby version.

## Consequences

- New Rubies installed through mise get `bundler` and `rails` automatically. A Ruby that is
  already installed does not; run `gem install bundler rails` once, or reinstall it.
- `aios-claude` installs into the current global Ruby. After the baseline Ruby changes
  (ADR 0003), run `bash ~/.dotfiles/ruby/install.sh` again, or `dot`, which does the same.
- `rails` makes each new Ruby install take noticeably longer.
- A new machine installed through `setup.sh` has no token yet, so the first run prints a note
  and skips `aios-claude`. That is expected.
- Existing `~/.default-gems` files are never overwritten (ADR 0012); the linker asks, backs up,
  and never deletes.
- Changing the public list is a one-line change to `ruby/default-gems.symlink`.
