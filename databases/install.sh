#!/usr/bin/env zsh

BREW_COMMAND=$(which brew)

echo "Force linking mysql and postgresql for their respective headers"
${BREW_COMMAND} link --force --overwrite mysql@8.4 >/dev/null
${BREW_COMMAND} link --force --overwrite postgres >/dev/null

exit 0
