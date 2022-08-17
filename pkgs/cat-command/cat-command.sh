#!/usr/bin/env bash

# A shortcut to print the contents of a shell command

set -euo pipefail

if [ -z "${1-}" ]; then
    echo "usage: $(basename "$0") [command] [bat flags for printing]"
    exit 1
fi

COMMAND="$1"
shift

if ! [ -x "$(command -v "${COMMAND}")" ]; then
    echo "error: command '${COMMAND}' does not exist or is not marked as executable"
    exit 1
fi

bat --plain $(whereis "${COMMAND}" | cut -d":" -f2 | xargs) $@
