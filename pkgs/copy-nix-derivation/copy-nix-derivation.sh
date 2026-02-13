#! /usr/bin/env bash

# Copy a derivation from a flake to a local path

set -euo pipefail

derivation="${1-empty}"
output="${2-default.nix}"
flake="nixpkgs"

while (($# > 0)); do
    case "$1" in
        -h | --help)
            echo "usage: copy-nix-derivation <derivation> [<output path> (default.nix)]"
            exit
            ;;
    esac
    shift
done

if [ "$derivation" = "empty" ]; then
    echo "error: no derivation specified."
    echo "usage: copy-nix-derivation <derivation> [<output path> (default.nix)]"
    exit 1
fi

if test -e "$output"; then
    echo "error: output path '$output' already exists."
    echo "usage: copy-nix-derivation <derivation> [<output path> (default.nix)]"
    exit 1
fi

if [[ $derivation =~ "#" ]]; then
    flake="${derivation%%#*}"
    derivation="${derivation##*#}"
fi

EDITOR=cat nix edit "$flake#$derivation" > "$output"
echo "copied $flake#$derivation to '$output'"
