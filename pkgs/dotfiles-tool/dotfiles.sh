#!/usr/bin/env bash

# Shortcuts for NixOS/Darwin system management

set -euo pipefail

error() {
    printf "\e[1;31merror:\e[0m %s\n" "$1"
    exit 1
}

runColored() {
    printf "\e[32m\$ %s\n\e[0m" "$1"
    eval "$1"
}

# Pick a rebuild command and handle platform differences
rebuildCommand() {
    local -r platform="$(uname -s)"
    case "$platform" in
        Darwin)
            echo "darwin-rebuild"
            ;;
        Linux)
            # '--use-remote-sudo' is required for NixOS but breaks on Darwin. This isn't the prettiest solution, but oh well.
            echo "nixos-rebuild --use-remote-sudo"
            ;;
        *)
            error "unsupported platform '$platform'"
            ;;
    esac
}

verboseLogs() {
    REBUILD_FLAGS+=("--print-build-logs")
    FLAKE_UPDATE_FLAGS+=("--print-build-logs")
    COLLECT_GARBAGE_FLAGS+=("--verbose")
}

# Handle user input
position=0
for arg in "$@"; do
    position=$((position + 1))
    case "$arg" in
        --dont-update|-u)
            DONT_UPDATE=1
            ;;
        --dont-collect-garbage|-g)
            DONT_COLLECT_GARBAGE=1
            ;;
        --print-build-logs|-l)
            verboseLogs
            ;;
        --debug|-d)
            DONT_UPDATE=1
            DONT_COLLECT_GARBAGE=1
            verboseLogs
            ;;
        --help|-h)
            usage_text="usage: $(basename "$0") [OPTIONS]\n"
            usage_text+="[-- FLAGS]                   pass all proceeding flags to the rebuild command\n"
            usage_text+="[--dont-update,-u]           dont update the flake\n"
            usage_text+="[--dont-collect-garbage,-g]  dont collect garbage\n"
            usage_text+="[--print-build-logs,-l]      print more verbose logs\n"
            usage_text+="[--debug,-d]                 shortcut for -u, -g and -l\n"
            usage_text+="[--help,-h]                  print this help message\n"
            echo -e "$usage_text"
            exit 0
            ;;
        --)
            REBUILD_FLAGS+=("${@:$((position + 1))}")
            break
            ;;
        *)
            error "Unknown argument \"$arg\""
            ;;
    esac
done
unset position

DOTFILES_DIR="${DOTFILES_DIR:-"$HOME/nix/dotfiles"}"
if [ ! -f "$DOTFILES_DIR/flake.nix" ]; then
    error "\"$DOTFILES_DIR\" is not a directory containing a flake! set DOTFILES_DIR to overwrite"
fi


# Start the rebuild procedure
runColored "cd \"$DOTFILES_DIR\""
if [ -z "${DONT_UPDATE-}" ]; then
    runColored "nix flake update ${FLAKE_UPDATE_FLAGS[*]-}"
fi

runColored "$(rebuildCommand) switch --flake . ${REBUILD_FLAGS[*]-}"

if [ -z "${DONT_COLLECT_GARBAGE-}" ]; then
    runColored "nix store gc ${COLLECT_GARBAGE_FLAGS[*]-}"
fi
