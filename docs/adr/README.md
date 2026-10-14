# Architecture Decision Records

Short records of significant decisions in this repo and why we made them, so
the next person (or us in a year) doesn't have to reverse-engineer the reasoning
from the code. Format: [Michael Nygard's ADRs](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
one file per decision, numbered in the order they were made.

## Index

| # | Decision | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-use-mise-for-runtimes-and-cli-tools.md) | Use mise for language runtimes and CLI tools | Accepted |
| [0003](0003-ruby-baseline-and-per-project-versions.md) | Ruby 4.0.6 is the global baseline; projects pick their own versions | Accepted |
| [0004](0004-two-phase-installer-with-saved-answers.md) | Two-phase installer (ask, then install) with saved answers and `--dry-run` | Accepted |
| [0005](0005-defaults-first-pickers-with-validated-free-form-entries.md) | Defaults-first pickers; validate free-form entries before installing | Accepted |
| [0006](0006-brewfile-holds-system-packages-only.md) | The Brewfile holds only what mise should not manage | Accepted |
| [0007](0007-ripgrep-and-gh-replace-ack-ag-hub.md) | ripgrep and gh replace ack, ag and hub | Accepted |
| [0008](0008-docker-without-docker-desktop.md) | Docker without Docker Desktop (Colima) | Accepted |
| [0009](0009-oh-my-zsh-with-generated-plugin-list.md) | oh-my-zsh with a generated plugin list; our aliases win | Accepted |
| [0010](0010-optional-neovim-lazyvim.md) | Optional Neovim + LazyVim alongside the existing vim setup | Accepted |
| [0011](0011-nerd-fonts-chosen-from-homebrew.md) | Nerd Fonts chosen from what Homebrew offers | Accepted |

## Adding one

1. Copy [`template.md`](template.md) to `NNNN-short-title.md` using the next number.
2. Fill it in. Keep it short: context, the decision, what else we considered, what
   it costs us.
3. Add it to the index above.

ADRs are not edited after the fact. If a decision changes, write a new ADR, set
the old one's status to `Superseded by NNNN`, and link both ways.
