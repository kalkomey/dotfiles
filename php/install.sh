#!/usr/bin/env zsh
#
# PHP 8.2 + Composer (see docs/package-matrix.md). Targets the modern,
# actively-maintained line (eRegulations / Craft CMS 4 pins 8.2); legacy PHP apps
# stay Dockerized. Independently runnable and safe to re-run.

set -e

OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    brew install php@8.2 composer
  else
    echo "php/install.sh: Homebrew missing; run homebrew/install.sh first" >&2
    exit 1
  fi
elif [[ "$OS" == "Linux" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  # PHP 8.2 isn't in Ubuntu 24.04 (noble ships 8.3); the ondrej/php PPA provides it.
  sudo apt-get install -y -qq software-properties-common
  sudo add-apt-repository -y ppa:ondrej/php
  sudo apt-get update -qq
  sudo apt-get install -y -qq \
    php8.2 php8.2-cli php8.2-common php8.2-mbstring php8.2-xml php8.2-curl php8.2-mysql unzip

  # Composer via the official installer, with the signature check it recommends.
  if ! command -v composer >/dev/null 2>&1; then
    expected="$(curl -fsSL https://composer.github.io/installer.sig)"
    curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php
    actual="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
    if [[ "$expected" == "$actual" ]]; then
      sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    else
      echo "php/install.sh: composer installer checksum mismatch — skipping composer" >&2
    fi
    rm -f /tmp/composer-setup.php
  fi
else
  echo "php/install.sh: unsupported OS '$OS'" >&2
  exit 1
fi
