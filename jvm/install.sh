#!/usr/bin/env zsh
#
# JDK 17 for JVM / Android builds (see docs/package-matrix.md). Gradle bootstraps
# per-repo via the wrapper; this provides the system JDK it needs (17+).
# Independently runnable and safe to re-run. JAVA_HOME is set in zsh/zshrc.symlink
# when a JDK 17 is present.

set -e

OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    brew install openjdk@17
  else
    echo "jvm/install.sh: Homebrew missing; run homebrew/install.sh first" >&2
    exit 1
  fi
elif [[ "$OS" == "Linux" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  sudo apt-get install -y -qq openjdk-17-jdk
else
  echo "jvm/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi

echo "JDK 17 installed. Open a new shell so JAVA_HOME is picked up."
