# 0006. The Brewfile holds only what mise should not manage

- Status: Accepted
- Date: 2026-10-14

## Context

The Brewfile had grown to cover compilers and build tools, languages' version managers, CLI tools, and
databases, much of it for reasons tied to the old Ruby setup (OpenSSL 1.1, binutils, bison, gcc). Several
entries no longer exist or are end of life (`mysql@5.7`, `openssl@1.1`, the `homebrew/bundle` and
`homebrew/services` taps, `amazon-ecs-cli`).

## Decision

With languages and CLI tools moving to mise ([0002](0002-use-mise-for-runtimes-and-cli-tools.md)), the
Brewfile keeps only what mise should not manage:

- core system tools: git, gnupg, coreutils, wget, nmap
- editors and terminal: vim, tmux, universal-ctags
- native libraries for compiling Ruby extensions: openssl@3, libyaml, readline, libffi, gdbm; plus imagemagick
- databases and services: memcached, redis, `mysql@8.4` (pinned; the current LTS), and `postgres`
  (Homebrew's alias for the latest PostgreSQL; nothing uses it today, it is there for people who want to try it)

We removed what is obsolete or replaced: nvm, ruby-install, openssl@1.1, the compiler toolchain
(autoconf, automake, bison, binutils, gcc, make, libksba), proctools, markdown, awslogs and amazon-ecs-cli
(`aws logs tail` covers the first; the second is legacy), `reattach-to-user-namespace` (modern tmux does not
need it, so the tmux config now calls `pbcopy` and `pbpaste` directly), and the built-in taps.

## Alternatives considered

- **Keep the whole old Brewfile**: preserves compatibility, but keeps dead packages and installs a toolchain
  nobody now needs.
- **Move databases into mise too**: they run as services, which mise does not manage.

## Consequences

- A much shorter, easier-to-audit Brewfile.
- `mysql@5.7` is no longer available in Homebrew, so MySQL is pinned to `mysql@8.4`, the current LTS. The stack
  currently runs 8.0, which Homebrew deprecated on 2026-04-30 because upstream no longer supports it (it will be
  disabled eventually), so we skipped it. The hard migration was 5.x to 8 (authentication), which is already done; 8.0 to
  8.4 is not expected to affect Rails/ActiveRecord apps, but this is a judgment call, not something we tested.
  Engineers whose local databases hold 8.0 data directories should check the upgrade path before starting the new server.
- `postgres` follows Homebrew's latest PostgreSQL, so a major version bump arrives on `brew upgrade`. Fine for trying it
  out; pin a `postgresql@NN` formula if anyone starts depending on it.
- Anyone relying on a dropped package must add it back (or request it via mise).
