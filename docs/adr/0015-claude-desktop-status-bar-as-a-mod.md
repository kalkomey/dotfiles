# 0015. Claude desktop status bar as a mod, installed by the dotfiles

- Status: Accepted
- Date: 2026-10-21

## Context

`claude/statusline.sh` (model, context bar, cost, duration) works in the Claude Code terminal through the `statusLine`
setting. The official docs describe that setting for the CLI only, so we could not rely on it in the Claude desktop app.
Every engineer's new Mac has Claude Code and the Claude desktop app installed, and runs the dotfiles installer once.

Claude Code mods (plugins that run JavaScript inside Claude Code) are documented to work in the Code tab of the desktop
app, and the `AbovePrompt` render site draws a band above the prompt there. `$.session.usage()` and `$.session.model()`
give the same figures the status line uses.

## Decision

`claude/mods/` is a one-plugin marketplace (`kalkomey-dotfiles`) holding the `kalkomey-statusbar` mod. `claude/install.sh`
adds the marketplace from the checkout and runs `claude plugin install kalkomey-statusbar@kalkomey-dotfiles` (user scope,
which the terminal and the desktop app share). The mod draws one dim line above the prompt, only where the surface is
`desktop`, because the terminal already has `statusline.sh`. It reads no files, runs no processes and uses no network.

## Alternatives considered

- **Patch the desktop app bundle**: fragile, breaks signing and updates, and is tampering with an app we do not own.
- **Load the mod with `CLAUDE_CODE_PLUGIN_DIRS` in settings.json**: avoids the marketplace but edits a file we otherwise
  leave alone, and bypasses `/plugin` so people cannot see or disable it.
- **Rely on `statusLine` alone**: unverified in the desktop app, and it cannot be drawn above the prompt.

## Consequences

- Needs the `claude` command on the machine when the installer runs. Without it the installer says how to run the step later.
- The marketplace points at `~/.dotfiles/claude/mods`; moving or deleting the checkout stops the mod loading.
- Mods are code that runs with the user's permissions. This one is small and reviewable (`claude plugin validate claude/mods/kalkomey-statusbar`).
- The mods API is new. The cost and start-time fields are read defensively and omitted if absent, so a change there degrades the line instead of breaking it.
