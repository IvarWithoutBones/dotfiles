#!/usr/bin/env bash

set -e

error() {
    printf "\e[1;31merror:\e[0m %s\n" "$1"
    exit 1
}

runColored() {
    printf "\e[32m\$ %s\n\e[0m" "$1"
    $1
}

if [ -z "${DOTFILES_DIR-}" ]; then
    DOTFILES_DIR="${HOME}/nix/dotfiles"
fi
if [ ! -d "${DOTFILES_DIR-}" ]; then
    error "Dotfiles directory \"${DOTFILES_DIR-}\" is not a directory!"
fi

flags="ugGlfdeh"

while getopts ":$flags" arg; do
    case $arg in
        u)
          DONT_UPDATE=1 ;;
        g)
          DONT_COLLECT_GARBAGE=1 ;;
        G)
          COLLECT_ALL_GARBAGE=1 ;;
        l)
          PRINT_BUILD_LOGS=1 ;;
        f)
          FAST_REBUILD=1 ;;
        d)
          export {DONT_UPDATE,DONT_COLLECT_GARBAGE,PRINT_BUILD_LOGS,FAST_REBUILD}=1 ;;
        e)
          if [ -z "${EDITOR-}" ]; then
              error "This flag requires the environment variable \"\$EDITOR\" to be set."
          elif [ ! -f "${DOTFILES_DIR-}/flake.nix" ]; then
              error "Flake \"${DOTFILES_DIR-}/flake.nix\" was not found!"
          fi

          OPEN_EDITOR=1 ;;
        h)
          usage_text="Usage: "$(basename "$0")" [-$flags]\n"
          usage_text+="[-u] Don't update the flake\n"
          usage_text+="[-g] Don't collect garbage\n"
          usage_text+="[-G] Run nix-collect-garbage as root, and pass it \"-d\"\n"
          usage_text+="[-l] Print more verbose logs\n"
          usage_text+="[-f] Pass \"--fast\" to nixos-rebuild\n"
          usage_text+="[-d] Set the flags \"-uglf\". This is useful when you're making small changes\n"
          usage_text+="[-e] Open the flake \"${DOTFILES_DIR-}/flake.nix\" in ${EDITOR-}\n"
          usage_text+="[-h] Print out the message you're seeing right now\n"
          printf "${usage_text-}"

          exit 0 ;;
        ?)
          error "Invalid option: \"-${OPTARG-}\"" ;;
    esac
done

if [ "${OPEN_EDITOR-}" ]; then
    "${EDITOR-}" "${DOTFILES_DIR-}/flake.nix"
    exit 0
fi

if [ "${PRINT_BUILD_LOGS-}" ]; then
    printLogs="--print-build-logs"
fi

if [ -z "${DONT_UPDATE-}" ]; then
    pushd "${DOTFILES_DIR-}" 1>/dev/null
    runColored "nix flake update ${dontWarnDirty} ${printLogs-}"
    popd 1>/dev/null
fi

rebuild_cmd="nixos-rebuild switch --use-remote-sudo ${printLogs-}"
if [ "${FAST_REBUILD-}" ]; then
    rebuild_cmd+=" --fast"
fi
runColored "${rebuild_cmd}"

if [ -z "${DONT_COLLECT_GARBAGE-}" ]; then
    garbage_cmd="nix store gc"

    if [ "${PRINT_BUILD_LOGS-}" ]; then
        garbage_cmd+=" --verbose"
    fi
    if [ "${COLLECT_ALL_GARBAGE-}" ]; then
        garbage_cmd="sudo nix-collect-garbage --delete-older-than 10d"
    fi

    runColored "${garbage_cmd}"
fi
