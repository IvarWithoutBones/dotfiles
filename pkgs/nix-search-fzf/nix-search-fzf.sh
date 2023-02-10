#!/usr/bin/env bash

# An fzf script with autocomplete from "nix search" which allows for interactive fuzzy searching of derivations.
# After the search a nix subcommand is executed on the selected derivation(s), e.g. "nix shell" or "nix run".

set -eou pipefail

FLAKE="nixpkgs"         # The default flake to use. TODO: make this configurable
NIX_SUBCOMMAND="shell"  # The default nix subcommand to execute
MULTIPLE_SELECTION=true # Wether to allow the user to select multiple derivations
PRINT_COMMAND=false     # Only print the command that would be executed, don't execute it

if [ -n "${XDG_CACHE_HOME-}" ]; then
	CACHE_PATH="$XDG_CACHE_HOME/nix-search-fzf/cache.txt"
else
	CACHE_PATH="$HOME/.cache/nix-search-fzf/cache.txt"
fi

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

	local cacheOutdated=false
	if (($(date -r "$CACHE_PATH" +%s) < $(date -d "now - 10 days" +%s))); then
		cacheOutdated=true
	fi

	if [ "$doUpdate" == "true" ] || [ "$cacheOutdated" == "true" ] || ! test -f "$CACHE_PATH"; then
		if $cacheOutdated; then
			echo "cache file is older than 10 days, updating"
		fi

		echo "caching attribute paths..."
		# Create a list of all attribute paths with "legacyPackages.$arch" stripped
		# In the future this could contain metadata as well, doing a "nix-eval" for each isnt the fastest
		nix search "$FLAKE" --json | jq -r 'keys[]' | cut -d'.' -f3- > "$CACHE_PATH"
		echo "succesfully cached the attribute paths"
	fi
}

runFzf() {
	local multi_flag
	if [ "$MULTIPLE_SELECTION" == true ]; then
		multi_flag="--multi"
	else
		multi_flag="--no-multi"
	fi

	fzf "$multi_flag" \
		--height=40% \
		--prompt="$NIX_SUBCOMMAND > " \
		--preview-window=right,70% \
		--border rounded \
		--preview "bash -c \"@previewText@ {} $FLAKE\"" < "$CACHE_PATH"
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
