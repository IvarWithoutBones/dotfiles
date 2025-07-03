#!/usr/bin/env bash

# Shortcuts for NixOS/Darwin system management

set -euo pipefail

USAGE="usage: $(basename "$0") [OPTIONS]
    [--update-flake, -u]        Update the flake.
    [--update-git, -U]          Update the git repository.
    [--collect-garbage, -g]     Collect garbage.
    [--print-logs, -l]          Print more verbose logs.
    [--fast, -f]                Pass '--fast' to the rebuild command.
    [--help, -h]                Print this help message, then exit.
    [-- FLAGS]                  Pass all proceeding flags to the rebuild command."

error() {
    if [[ -z ${NO_COLOR:-} ]]; then
        echo -e "\e[1;31merror:\e[0m $1\e[0m" >&2
    else
        echo "error: $1" >&2
    fi
    (($# > 1)) && echo "${@:2}" >&2
    exit 1
}

runColored() {
    if [[ -z ${NO_COLOR:-} ]]; then
        echo -e "\e[32m\$ $1\e[0m" >&2
    else
        echo "\$ $1" >&2
    fi
    eval "$1"
}

# Pick a rebuild command based on the platform
rebuildCommand() {
    local platform
    platform="$(uname --kernel-name)"
    case "${platform}" in
        Darwin)
            echo "darwin-rebuild"
            ;;
        Linux)
            echo "nixos-rebuild"
            ;;
        *)
            error "unsupported platform '${platform}'"
            ;;
    esac
}

# Handle arguments
position=0
for arg in "$@"; do
    position=$((position + 1))
    case "${arg}" in
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
            echo "${USAGE}"
            exit 0
            ;;
        --)
            REBUILD_FLAGS+=("${@:$((position + 1))}")
            break
            ;;
        *)
            error "unknown argument '${arg}'" "${USAGE}"
            ;;
    esac
done
unset position

# Go into the dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/nix/dotfiles"}"
if [[ ! -f "${DOTFILES_DIR}/flake.nix" ]]; then
    error "'${DOTFILES_DIR}' is not a directory containing a flake! set DOTFILES_DIR to overwrite"
fi
runColored "cd \"${DOTFILES_DIR}\""

# Update the git repository
if [[ -n ${UPDATE_GIT-} ]]; then
    runColored "git pull"
fi

# Update the flake
if [[ -n ${UPDATE_FLAKE-} ]]; then
    runColored "nix flake update ${FLAKE_UPDATE_FLAGS[*]-}"
fi

# Rebuild the system
platform="$(uname --kernel-name)"
rebuildCommand="$(rebuildCommand)"
if [[ ${platform} == "Linux" ]]; then
    # Required for NixOS but breaks on Darwin.
    REBUILD_FLAGS+=("--sudo")
fi
REBUILD_FLAGS+=("--flake" ".")
runColored "${rebuildCommand} switch ${REBUILD_FLAGS[*]-}"

# Collect garbage
if [[ -n ${COLLECT_GARBAGE-} ]]; then
    runColored "nix store gc ${COLLECT_GARBAGE_FLAGS[*]-}"
fi
