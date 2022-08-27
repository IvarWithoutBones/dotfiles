#! /usr/bin/env bash

set -euo pipefail

if test -z "${1-}"; then
    echo "usage: $0 <MacOS alias file>"
    exit 1
fi

file="$(realpath "$1")"
# Not entirely sure how accurate this is, but seemed to work fine with my tests.
strings "$file" | grep "file://" | tail -n1 | cut -d'/' -f3-
