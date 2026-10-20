# 0012. Never overwrite existing dotfiles: ask, back up, never delete

- Status: Accepted
- Date: 2026-10-20

## Context

This repo started as a bootstrap for new machines, but most engineers who run it already have a setup. Two cases:

1. They have dotfiles in place that this repo knows nothing about (a hand-edited `~/.zshrc`, `~/.gitconfig`, ...).
2. They manage their dotfiles with GNU Stow (or similar), so `~/.zshrc` is a symlink into their own dotfiles repo.

The old `script/bootstrap` asked skip / overwrite / backup per file, but "overwrite" ran `rm -rf`, "backup" left
`.backup` files beside the originals, and there was no way to compare or combine. For stow users, anything that writes
*through* a symlink edits a tracked file in their repo.

## Decision

Nothing is deleted, and nothing existing is replaced without an answer.

- `script/lib/link.sh` links each `*.symlink` into `$HOME`. If the destination is missing, or already our link, there is
  nothing to ask. A plain copy identical to ours is replaced silently (and still backed up).
- On any other conflict it says what is there (a file, a directory, a symlink and where it points, flagging relative
  links as stow-style) and asks: **[k]eep** yours, **[n]ew** (use ours), **[m]erge**, or **[d]iff**. `K` and `N` apply
  the answer to every remaining conflict.
- **Keep** touches nothing. **New** and **merge** first move the original into `~/.dotfiles-backup/<timestamp>/`,
  mirroring its path under `$HOME`.
- **Merge** opens a diff editor (`vimdiff`, or `MERGE_TOOL`) with a copy of your file on the left and ours on the right.
  The saved left file replaces yours as a *plain file*. If nothing was saved, nothing changes and you are asked again.
  Merge is offered only for single files; for directories such as `~/.vim`, use diff.
- Symlinks are handled as links. The backup of a stow link is an absolute link to the same file (a relative one would dangle
  from the backup directory), and the log records the original target. We never write through a symlink, so the stow
  repo is not modified.
- Without a terminal (`curl | bash` in CI, say) conflicts are kept, not guessed. `DOTFILES_LINK=keep|new` sets the answer
  up front.
- `script/bootstrap --dry-run` lists each destination as new, already linked, or a conflict, without asking or changing
  anything.
- The other writers follow the same rule: `zsh/install.sh` will not append to a `~/.zshenv` that is a symlink (it prints
  the line to add), and `mise/install.sh` copies an existing mise `config.toml`/`settings.toml` into the backup directory
  before `mise use --global` edits it.

## Alternatives considered

- **Detect stow and switch to stow mode**: would need the repo laid out as stow packages and still cannot know the user's
  package names.
- **Backups beside the originals (`.zshrc.backup`)**: clutters `$HOME`, collides on a second run, and in a stow-managed
  directory lands inside someone's repo.
- **Auto-merge** (`git merge-file` with an empty base): with no common ancestor, nearly every line conflicts, so a person
  has to resolve it anyway; a two-pane editor is clearer.
- **Remember "keep" answers**: fewer repeat questions, but a stale answer is hard to notice and change.

## Consequences

- Safe to run on a configured machine, and easy to undo: move the file back from the backup directory.
- A merged file is no longer a link into the repo, so later repo changes to it do not arrive; re-run and choose **new**
  to go back.
- If `~/.zshrc` is kept or merged without our lines, mise and the oh-my-zsh plugins are not loaded. The installer prints
  the lines to add after a **keep**.
- Stow users who pick **new** will see a stow conflict on their next restow for those files.
- Bootstrap asks again on every run for files that are still in conflict.
- Both interactive paths (the answers and the editor) read from `/dev/tty`, so they work when the script is piped.
