#!/usr/bin/env bash

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/script/lib/common.sh"

load_brew || die "Homebrew is not installed. Run script/ask (it installs Homebrew), or bin/dot."

echo "Force linking mysql and postgresql for their respective headers"
brew link --force --overwrite mysql@8.4 >/dev/null
brew link --force --overwrite postgres >/dev/null

exit 0
