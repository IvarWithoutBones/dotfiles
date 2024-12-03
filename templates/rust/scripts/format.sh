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
	readarray -d "" files < <(fd --print0 --hidden --absolute-path --type file --extension "${ext}" || true)
	runCommand "${cmd[@]}" "${files[@]}"
}

# Enter the root of the git repository.
gitRoot="$(git rev-parse --show-toplevel || (echo "not inside of a git repository" >&2 && exit 1))"
cd "${gitRoot}"

# Rust
runCommand "cargo" "fmt"

# TOML
formatFilesWithExtension "toml" "taplo" "fmt"

# Nix
formatFilesWithExtension "nix" "nixpkgs-fmt"

# YAML
formatFilesWithExtension "yml" "yamlfmt"

# Shell scripts
formatFilesWithExtension "sh" "shfmt" "--simplify" "--write"
