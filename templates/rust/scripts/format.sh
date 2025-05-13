#!/usr/bin/env bash

# This script automatically formats a bunch of different file types.

set -euo pipefail

# Print out the given command in green and run it afterwards.
runCommand() {
    local cmd="$1" args=("${@:2}")
    echo -ne "\e[32m\$ ${cmd} ${args[*]}\n\e[0m" >&2
    ${cmd} "${args[@]}"
}

# Run a command supplied with each file with the given extension as an argument.
formatFilesWithExtension() {
    local files ext="$1" cmd=("${@:2}")
    readarray -d "" files < <(git ls-files -z --exclude-standard "*.${ext}" || true)
    if ((${#files[@]} > 0)); then
        runCommand "${cmd[@]}" "${files[@]}"
    fi
}

# Enter the root of the git repository.
gitRoot="$(git rev-parse --show-toplevel || (echo "not inside of a git repository" >&2 && exit 1))"
cd "${gitRoot}"

runCommand "cargo" "fmt"                                     # Rust
formatFilesWithExtension "toml" "taplo" "fmt"                # TOML
formatFilesWithExtension "nix" "nixpkgs-fmt"                 # Nix
formatFilesWithExtension "yml" "yamlfmt"                     # YAML
formatFilesWithExtension "sh" "shfmt" "--simplify" "--write" # Shell scripts
