# 0005. Defaults-first pickers; validate free-form entries before installing

- Status: Accepted
- Date: 2026-10-14

## Context

Engineers need sensible defaults (most just want our standard setup) but also need to install other
languages, versions, tools and fonts. mise and Homebrew have hundreds of options, so a fixed menu will
never be complete. Free-form input invites typos, and a bad name found halfway through a Ruby compile
wastes the most time.

## Decision

Each choice (languages, CLI tools, Nerd Fonts, oh-my-zsh plugins) is a checklist with defaults already
selected; pressing Enter accepts them. Engineers toggle items by number, set a version with `N=version`
(languages), and can type any other `name` or `name@version`.

Anything the engineer typed or edited is validated before the installs start: tool names and versions with
`mise latest`, font names against Homebrew casks. A bad entry returns the picker to the menu with a warning.
Environment-variable overrides are validated the same way and fail fast. Defaults and previously saved
answers are not re-validated.

The Nerd Font list is read from Homebrew at install time, and only the defaults are shown at first (`m` shows
more). Without a terminal (CI), the defaults are used.

## Alternatives considered

- **Fixed menus only**: simple, but cannot cover what engineers actually need.
- **Free text only**: flexible, but gives no discoverability and no defaults.
- **Validate everything every run**: slow (a network call per entry) and risks blocking on a good default
  because of a transient failure.
- **Validate lazily at install time**: simplest, but fails after the slow steps.

## Consequences

- Fast path for the common case, escape hatch for everything else.
- Validation needs mise and Homebrew present, so it runs after they are installed (see
  [0004](0004-two-phase-installer-with-saved-answers.md)); under `--dry-run` without them it is skipped with a
  warning.
- `latest`, `lts` and `stable` are checked by tool name only, since not every mise backend accepts those
  aliases.
- Unvalidated defaults mean a mise registry rename would break a default until the list is updated.
