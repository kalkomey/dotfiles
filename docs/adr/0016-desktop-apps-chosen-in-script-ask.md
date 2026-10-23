# 0016. Desktop apps are chosen in `script/ask`, not listed in the Brewfile

- Status: Accepted
- Date: 2026-10-23

## Context

The Brewfile installs everything in it for everyone ([0006](0006-brewfile-holds-system-packages-only.md)). That suits
system packages. It does not suit desktop apps: terminals, editors and note-taking apps are personal choices, and
people on the team already run different ones. Putting `cask "obsidian"` in the Brewfile would install it, and any
app added later, on every machine.

## Decision

We added an **Applications** question to `script/ask`, with its own topic directory, `apps/`, like `fonts/`.

- The list is Homebrew cask names: cmux, ghostty, kitty, obsidian, rectangle, sequel-ace, sublime-text, tldraw and zed. Only
  None is on by default, because IT's machine image already installs the security and standard apps (Firefox, for
  example), so this list only holds optional extras.
- Engineers can type any other cask name. It is checked with `brew info --cask` before anything installs
  ([0005](0005-defaults-first-pickers-with-validated-free-form-entries.md)).
- The answer is saved as `APPS` in `~/.config/dotfiles/install-choices`. `APPS="..."` skips the question and
  `APPS=none` means no apps. A saved-answers file from before this change has no `APPS`, so only this question is
  asked.
- `apps/install.sh` installs the chosen casks with `--adopt`, so an app already in `/Applications` is taken over by
  Homebrew instead of failing with "already an App at".
- `bin/dot` runs `apps/install.sh` after the fonts step. The Brewfile no longer lists any casks.

## Alternatives considered

- **Casks in the Brewfile**: simplest, but installs every app for everyone.
- **A separate `Brewfile.apps`**: still all-or-nothing, and it does not validate typed names or save answers.
- **Preselect some apps**: the machine image already covers the standard set, so a preselected app would only
  duplicate it or install something someone did not want.

## Consequences

- Adding an app to the list is a one-line edit in `apps/ask.sh` (name, description, and a `0` in `APP_ON`).
- `--adopt` hands management of an existing app to Homebrew, so `brew upgrade` can then replace it. Apps that
  update themselves are unaffected.
- The descriptions are hand-written and can drift from what Homebrew says about each cask.
