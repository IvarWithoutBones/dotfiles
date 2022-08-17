#!/usr/bin/env bash

# Quickly create an executable script with a nix-shell shebang

set -euo pipefail

if [ -z "${1-}" ]; then
    echo "usage: $(basename "$0") [script name]"
    exit 1
fi

if [ -f "${1}" ] || [ -d "${1}" ]; then
    echo "error: '${1}' already exists"
    exit 1
fi

echo '#! /usr/bin/env nix-shell
#! nix-shell -i bash
' > "${1}"

chmod +x "${1}"
