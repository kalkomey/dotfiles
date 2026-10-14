# 0007. ripgrep and gh replace ack, ag and hub

- Status: Accepted
- Date: 2026-10-14

## Context

The repo used `ack` (`bin/search`, `~/.ackrc`, `ack.vim`), `the_silver_searcher` (`ag.vim`), and wrapped `git` with
`hub`. All three have been superseded: ripgrep is faster and respects `.gitignore` by default, `ag.vim` is deprecated
in favor of `ack.vim` (which can drive ripgrep), and `gh` (already in the Brewfile) replaced `hub`.

## Decision

- `bin/search` calls `rg`.
- `~/.ackrc` becomes `~/.ripgreprc` (`system/ripgreprc.symlink`, loaded via `RIPGREP_CONFIG_PATH` in
  `system/env.zsh`), keeping the custom file types and the `log`, `tags` and `tmp` ignores.
- `ag.vim` is removed (and its old checkout deleted); `ack.vim` is kept and pointed at ripgrep with
  `g:ackprg`. `:Ag` stays as a command alias for muscle memory.
- The `git()` shell function no longer prefers `hub`; it calls `git` directly.

## Alternatives considered

- **Keep ack/ag**: still work, but slower and unmaintained, and they would keep two extra packages in the Brewfile.
- **Replace ack.vim with fzf-based search**: a bigger change to how people search in vim than this effort warrants.
- **Keep `hub`**: GitHub's own CLI (`gh`) covers it and is actively developed.

## Consequences

- One search tool everywhere (shell, vim).
- Anything that shelled out to `ack`, `ag` or `hub` directly must be updated; we found none beyond the files above.
- ripgrep's ignore handling differs slightly from ack's (for example hidden files); use `--hidden --no-ignore` to
  search everything.
