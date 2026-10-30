# 0003. Ruby 4.0.6 is the global baseline; projects pick their own versions

- Status: Accepted
- Date: 2026-10-14

## Context

The old installers pinned Ruby 3.0.5 and 3.1.4 and Node 10.15 and 13.0.1, all long past end of
life. Our applications currently all run on Ruby 4.0.6. We also need to let engineers install
other languages and versions for specific work.

## Decision

The installer's default global languages are **Ruby 4.0.6** (our baseline for all applications)
and **Node LTS**. Other languages (Python, Go, Rust, Java, Elixir) are offered but off by default,
and any other mise tool can be added as `name@version` or `name@latest`.

Global versions are only a default. A project's own `.tool-versions`, `mise.toml`,
`.ruby-version` or `.node-version` always takes precedence in that directory.

## Alternatives considered

- **Install several Rubies globally** (as the old script did): wastes compile time, and
  mise can install the right one on demand when a project asks for it.
- **Track `ruby@latest`**: the baseline is a deliberate, shared choice, not whatever is newest.
- **No global default**: a fresh machine would have no working `ruby` or `node` until the
  engineer entered a project.

## Consequences

- A new machine matches what applications run.
- Moving the baseline is a one-line change to `LANG_VERS` in `mise/ask.sh`, plus a note in a
  new ADR if the reason is worth keeping. Engineers with saved answers keep the version they
  chose until they run `RECONFIGURE=1 bin/dot`.
- Node is `lts`, which moves over time; projects that need a specific Node should pin it.
