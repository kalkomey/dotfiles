# 0002. Use mise for language runtimes and CLI tools

- Status: Accepted
- Date: 2026-10-14

## Context

Language and tool versions were managed by several unrelated mechanisms: nvm for Node,
ruby-install (with a hand-built openssl@1.1 configuration) for Ruby, tfenv for Terraform,
and plain Homebrew formulae for AWS CLI, Vault, Nomad, Consul, gh, jq, fzf and others. Each
had its own install script, shell hook and upgrade story, and pinned versions had drifted far
behind (Ruby 3.0/3.1, Node 10/13). The repo had already started moving this way: `zshrc`
activated mise and a recent commit replaced chruby with it for Ruby.

All our engineers use macOS, and projects already express versions in `.ruby-version`,
`.node-version` or `.tool-versions`.

## Decision

We will use [mise](https://mise.jdx.dev) as the single manager for language runtimes and
CLI tools, installed globally with `mise use --global`. We replace `node/install.sh` (nvm) and
`ruby/install.sh` (ruby-install) with `mise/install.sh`, and move tfenv, awscli, aws-vault, gh,
jq, fzf, ripgrep, vault, nomad, consul, direnv, git-lfs, gron and yarn from Homebrew to mise.

mise is enabled to honor legacy `.ruby-version` and `.node-version` files so existing
repositories work without migrating to `.tool-versions`.

## Alternatives considered

- **Keep nvm + ruby-install + tfenv**: three tools, three shell hooks, and the Ruby script
  needed OpenSSL 1.1 workarounds that no longer make sense.
- **asdf**: the same model as mise, but slower and with less built in. The README already
  mentioned it as a "custom install" option; mise is largely compatible with its
  `.tool-versions` files.
- **Everything from Homebrew**: Homebrew keeps one version of each formula, which is a poor
  fit for per-project Ruby and Node versions.

## Consequences

- One tool to learn, one shell hook, one place that says what is installed.
- Engineers can pin tools per project the same way they pin languages.
- mise tool names come from its registry; a mistyped or renamed tool fails at install time
  (see [0005](0005-defaults-first-pickers-with-validated-free-form-entries.md)).
- Compiled Ruby still needs native libraries from Homebrew
  (see [0006](0006-brewfile-holds-system-packages-only.md)).
