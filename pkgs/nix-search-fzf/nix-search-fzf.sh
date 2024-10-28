#!/usr/bin/env bash

# An fzf script with autocomplete from "nix search" which allows for interactive fuzzy searching of derivations.
# After the search a nix subcommand is executed on the selected derivation(s), e.g. "nix shell" or "nix run".

set -eou pipefail

FLAKE="nixpkgs"         # The default flake to use. TODO: make this configurable
NIX_SUBCOMMAND="shell"  # The default nix subcommand to execute
MULTIPLE_SELECTION=true # Whether to allow the user to select multiple derivations
PRINT_COMMAND=false     # Only print the command that would be executed, don't execute it

if [ -n "${XDG_CACHE_HOME-}" ]; then
	CACHE_PATH="$XDG_CACHE_HOME/nix-search-fzf/cache.txt"
else
	CACHE_PATH="$HOME/.cache/nix-search-fzf/cache.txt"
fi

# Because fzf executes commands from keybindings in a subprocess, we cannot directly change this scripts state.
# Instead we can use a temporary file as an IPC mechanism, to change which subcommand to execute.
TMP_FILE="$(mktemp --dry-run --suffix "-nix-search-fzf")"
trap 'rm -f "$TMP_FILE"' EXIT INT TERM

handleArguments() {
	while (("$#" > 0)); do
		case "$1" in
			-s | shell | --shell)
				NIX_SUBCOMMAND="shell"
				;;
			-b | build | --build)
				NIX_SUBCOMMAND="build"
				;;
			-r | run | --run)
				NIX_SUBCOMMAND="run"
				MULTIPLE_SELECTION=false
				;;
			-e | edit | --edit)
				NIX_SUBCOMMAND="edit"
				MULTIPLE_SELECTION=false
				;;
			-c | command | --command)
				PRINT_COMMAND=true
				;;
			-u | update | --update)
				manageCache true
				exit
				;;
			-h | help | --help)
				echo "Usage: $(basename "$0") [--shell|--build|--run|--edit|--update]"
				echo "  --shell: enter a nix shell with the selected package(s). This is the default"
				echo "  --build: build the selected package(s) with nix build"
				echo "  --run: run the selected package with nix run"
				echo "  --edit: edit the selected package with nix edit"
				echo "  --command: only print the command that would be executed, don't execute it"
				echo "  --update: update the nix search cache, this is done automatically every 10 days"
				echo "  --help: show this help message"
				exit 0
				;;
			*)
				echo "Unknown option '$1'"
				exit 1
				;;
		esac
		shift 1
	done
}

runColored() {
	printf "\e[32m\$ %s\n\e[0m" "$1"
	eval "$1"
}

manageCache() {
	local doUpdate="${1:-false}"
	mkdir -p "$(dirname "$CACHE_PATH")"

	if [ ! -f "$CACHE_PATH" ] || [ ! -s "$CACHE_PATH" ]; then
		doUpdate="true"
		echo "attribute path cache does not exist, generating..." >&2
	elif (($(date -r "$CACHE_PATH" +%s) < $(date -d "now - 10 days" +%s))); then
		doUpdate="true"
		echo "cache file is older than 10 days, updating..." >&2
	fi

	if [ "$doUpdate" == "true" ]; then
		echo "caching attribute paths..." >&2
		# Create a list of all attribute paths with "legacyPackages.$arch" stripped
		# In the future this could contain metadata as well, doing a "nix-eval" for each is not the fastest
		nix search "$FLAKE" "^" --quiet --json | jq -r 'keys[]' | cut -d'.' -f3- > "$CACHE_PATH"
		echo "successfully generated attribute path cache" >&2
	fi
}

fzfBindingFlag() {
	local tmpFile="$1"
	local -A bindings=(
		["shell"]="ctrl-s"
		["build"]="ctrl-b"
		["edit"]="ctrl-e"
		["run"]="ctrl-r"
	)

	local result="--bind="
	for subCommand in "${!bindings[@]}"; do
		local binding="${bindings[$subCommand]}"
		# When pressed, write the appropriate command to our temporary IPC file, and change the prompt accordingly
		result+="$binding:execute-silent(echo $subCommand > $tmpFile)+change-prompt($subCommand > ),"
	done
	echo "${result%,}"
}

runFzf() {
	local multi_flag
	if [ "$MULTIPLE_SELECTION" == true ]; then
		multi_flag="--multi"
	else
		multi_flag="--no-multi"
	fi

	fzf "$multi_flag" \
		--height 40% \
		--preview-window right,70% \
		--border rounded \
		--prompt "$NIX_SUBCOMMAND > " \
		--preview "bash -c \"@previewText@ {} $FLAKE\"" \
		"$(fzfBindingFlag "$TMP_FILE")" < "$CACHE_PATH"
}

runNix() {
	local packages selectedPkgs command
	readarray -t selectedPkgs <<< "$@"
	((${#selectedPkgs[@]} == 0)) && exit 0

	if [ "$MULTIPLE_SELECTION" == true ] && ((${#selectedPkgs[@]} > 1)); then
		# Build a brace expansion string
		local pkg_list="{"
		for pkg in "${selectedPkgs[@]}"; do
			pkg_list+="$pkg,"
		done
		packages="${pkg_list%,}}"
	else
		packages="${selectedPkgs[0]}"
	fi

	((${#packages} == 0)) && exit 0

	# Update what subcommand to execute, in case it was changed by a keybinding from fzf
	[ -s "$TMP_FILE" ] && NIX_SUBCOMMAND="$(< "$TMP_FILE")"

	command="NIXPKGS_ALLOW_UNFREE=1 nix $NIX_SUBCOMMAND $FLAKE#$packages --impure"
	if [ "$PRINT_COMMAND" == true ]; then
		echo "$command"
		exit 0
	else
		runColored "$command"
	fi
}

handleArguments "$@"
manageCache
runNix "$(runFzf)"
