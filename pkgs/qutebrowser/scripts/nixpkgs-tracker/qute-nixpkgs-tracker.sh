#! /usr/bin/env bash

# Qutebrowser userscript to open the CI tracker for a nixpkgs PR
# Usage: `:spawn --userscript qute-nixpkgs-tracker.sh {url}`

set -euo pipefail
url="$1"

if ! [[ "${url,,}" =~ https://github.com/nixos/nixpkgs/pull/[0-9]+ ]]; then
    echo "message-error 'not a nixpkgs PR'" >> "$QUTE_FIFO"
    exit
fi

pr="$(grep -o '[0-9]\+' <<< "$url" | head -n1)"
if test -z "$pr"; then
    echo "message-error 'could not extract PR number'" >> "$QUTE_FIFO"
    exit
fi

echo "open --tab https://nixpk.gs/pr-tracker.html?pr=$pr" >> "$QUTE_FIFO"
echo "message-info 'loading PR tracker for #$pr" >> "$QUTE_FIFO"
