#!/usr/bin/env bash

# Shortcuts for NixOS/Darwin system management

set -euo pipefail

error() {
	echo -ne "\e[1;31merror:\e[0m $1\n"
	exit 1
}

runColored() {
	echo -ne "\e[32m\$ $1\n\e[0m"
	eval "$1"
}

# Pick a rebuild command based on the platform
rebuildCommand() {
	local -r platform="$(uname -s)"
	case "$platform" in
		Darwin)
			echo "darwin-rebuild"
			;;
		Linux)
			echo "nixos-rebuild"
			;;
		*)
			error "unsupported platform '$platform'"
			;;
	esac
}

helpMessage() {
	cat << EOF
usage: $(basename "$0") [OPTIONS]
    [--update-flake, -u]        Update the flake.
    [--update-git, -U]          Update the git repository.
    [--collect-garbage, -g]     Collect garbage.
    [--print-logs, -l]          Print more verbose logs.
    [--fast, -f]                Pass '--fast' to the rebuild command.
    [--help, -h]                Print this help message, then exit.
    [-- FLAGS]                  Pass all proceeding flags to the rebuild command.
EOF
}

# Handle arguments
position=0
for arg in "$@"; do
	position=$((position + 1))
	case "$arg" in
		--update-flake | -u)
			UPDATE_FLAKE=1
			;;
		--update-git | -U)
			UPDATE_GIT=1
			;;
		--collect-garbage | -g)
			COLLECT_GARBAGE=1
			;;
		--print-logs | -l)
			REBUILD_FLAGS+=("--print-build-logs")
			FLAKE_UPDATE_FLAGS+=("--print-build-logs")
			COLLECT_GARBAGE_FLAGS+=("--verbose")
			;;
		--fast | -f)
			REBUILD_FLAGS+=("--fast")
			;;
		--help | -h)
			helpMessage
			exit 0
			;;
		--)
			REBUILD_FLAGS+=("${@:$((position + 1))}")
			break
			;;
		*)
			error "Unknown argument \"$arg\".\n$(helpMessage)"
			;;
	esac
done
unset position

# Go into the dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-"$HOME/nix/dotfiles"}"
if [ ! -f "$DOTFILES_DIR/flake.nix" ]; then
	error "\"$DOTFILES_DIR\" is not a directory containing a flake! set DOTFILES_DIR to overwrite"
fi
runColored "cd \"$DOTFILES_DIR\""

# Update the git repository
if [ -n "${UPDATE_GIT-}" ]; then
	runColored "git pull"
fi

# Update the flake
if [ -n "${UPDATE_FLAKE-}" ]; then
	runColored "nix flake update ${FLAKE_UPDATE_FLAGS[*]-}"
fi

# Rebuild the system
if [ "$(uname -s)" = "Linux" ]; then
	# Required for NixOS but breaks on Darwin.
	REBUILD_FLAGS+=("--use-remote-sudo")
fi
REBUILD_FLAGS+=("--flake" ".")
runColored "$(rebuildCommand) switch ${REBUILD_FLAGS[*]-}"

# Collect garbage
if [ -n "${COLLECT_GARBAGE-}" ]; then
	runColored "nix store gc ${COLLECT_GARBAGE_FLAGS[*]-}"
fi
