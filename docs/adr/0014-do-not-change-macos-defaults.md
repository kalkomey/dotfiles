# 0014. Do not change macOS system defaults

- Status: Accepted
- Date: 2026-10-20

## Context

`bin/dot` used to run `osx/set-defaults.sh`, a 272-line script adapted from Mathias Bynens' dotfiles (around 2013). It asked
for an administrator password, wrote dozens of settings (Dock, Finder, Safari, Mail, login window, and more), and ran every
time with no question. On a current Mac it also failed noisily: `sudo -v` was refused or declined and the script carried
on regardless, and every write to Safari's preferences errored because macOS protects that container. The settings
are one person's preferences from a decade ago, and some no longer exist.

## Decision

We removed `osx/set-defaults.sh` and the `bin/set-defaults` wrapper, and `bin/dot` no longer touches macOS settings.
The installer needs no administrator password for its own work (Homebrew's installer asks for one if Homebrew is missing).

## Alternatives considered

- **Keep it but make it opt-in**: still 272 lines of unreviewed settings that nobody here chose, plus the admin prompt.
- **Trim it to a few settings**: engineers have their own preferences for these; a shared installer is the wrong place
  to set them.

## Consequences

- No surprise system changes and no sudo prompt from the installer.
- Anyone who wants specific settings can keep a script of their own. The old one is in this repo's git history.
