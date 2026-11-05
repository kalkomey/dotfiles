# 0011. Nerd Fonts chosen from what Homebrew offers

- Status: Accepted
- Date: 2026-10-14

## Context

LazyVim, powerline-style prompts and many terminal tools use icon glyphs that only a Nerd Font provides. People have
strong, personal font preferences (the team likes FiraCode and DejaVu Sans Mono; many like ligatures), and Homebrew
packages dozens of Nerd Fonts as casks named `font-<name>-nerd-font`.

## Decision

The installer offers a font picker. **FiraCode and DejaVu Sans Mono are listed and selected by default.** Typing `m`
shows the rest, and the list is read from Homebrew at install time (`brew search --casks`), so it always matches what can
be installed (with a short built-in list as a fallback if the search fails). The picker links to
<https://www.nerdfonts.com/font-downloads> for previews. Engineers can also type a short name such as `hack`; it is
checked against Homebrew before installing. Selected fonts are installed with `brew install --cask`.

After installing, the script reminds people to set their terminal font to the family name (for example "FiraCode Nerd
Font") and that ligatures need a terminal that supports them (iTerm2 does; Terminal.app does not).

## Alternatives considered

- **One mandated font**: simplest, but fonts are personal.
- **A hard-coded list**: goes stale as Homebrew adds and removes casks.
- **Show all of them up front**: dozens of entries bury the two defaults.
- **Configure the terminal's font automatically**: depends on which terminal app each engineer uses, so we only
  instruct.

## Consequences

- Engineers can preview and pick, with sensible defaults.
- Ligature tags in the picker are a small hand-maintained list and may be incomplete; fonts without a tag are not
  necessarily ligature-free.
- Selecting several large font families takes a little disk space and download time.
