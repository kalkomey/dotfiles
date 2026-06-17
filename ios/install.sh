#!/usr/bin/env zsh
#
# iOS toolchain — macOS only (see docs/package-matrix.md). Installs the Command
# Line Tools, CocoaPods, and SwiftLint. Xcode.app itself comes from the Mac App
# Store and is not scripted here; Fastlane is per-repo via Bundler. No-ops on Linux.

set -e

if [[ "$(uname)" != "Darwin" ]]; then
  echo "ios/install.sh: macOS only — skipping on $(uname)"
  exit 0
fi

# Command Line Tools. xcode-select --install opens a GUI prompt; non-fatal if
# already installed.
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "Finish the Command Line Tools install in the macOS prompt, then re-run."
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "ios/install.sh: Homebrew missing; run homebrew/install.sh first" >&2
  exit 1
fi

brew install cocoapods swiftlint

echo "Install Xcode.app from the Mac App Store for full iOS builds; Fastlane is per-repo via Bundler."
