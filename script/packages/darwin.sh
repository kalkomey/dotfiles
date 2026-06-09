#!/usr/bin/env bash
#
# packages/darwin.sh
#
# macOS package installation: Xcode Command Line Tools, Homebrew, and `brew
# bundle` (formulae + casks from homebrew/Brewfile). This is a thin wrapper
# around the existing Homebrew topic installer so there is a single source of
# Homebrew bootstrap logic; it exists to give macOS a symmetric per-OS entry
# point alongside packages/ubuntu.sh.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"

exec "$HERE/homebrew/install.sh"
