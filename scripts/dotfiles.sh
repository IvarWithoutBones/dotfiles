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

if [ -z "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$HOME/nix/dotfiles"
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory \""$DOTFILES_DIR"\" was not found!"
fi

while getopts ":lgfeh" arg; do
    case $arg in
        l)
          DONT_UPDATE=1
          ;;
        g)
          DONT_COLLECT_GARBAGE=1
          ;;
        f)
          export {FAST_REBUILD,DONT_UPDATE,DONT_COLLECT_GARBAGE}=1
          ;;
        e)
          if [ -z "$EDITOR" ]; then
            error "This flag requires the environment variable \"\$EDITOR\" to be set."
          fi
          OPEN_EDITOR=1
          ;;
        h)
          printf \
            "Usage: "$(basename "$0")" [-lgfeh]\n%s\n%s\n%s\n%s\n%s\n" \
            "[-l] Don't update the flake, just do a local rebuild" \
            "[-g] Don't collect garbage" \
            "[-f] Pass \"--fast\" to nixos-rebuild, and set \"-lg\"" \
            "[-e] Open the flake \""$DOTFILES_DIR"/flake.nix\" in \""$EDITOR"\"" \
            "[-h] Print out the message you're seeing right now" \
          && exit 0 ;;
    esac
done

if [[ ! -f ""$DOTFILES_DIR"/flake.nix" && ! -z "$OPEN_EDITOR" ]]; then
    error "Flake \""$DOTFILES_DIR"/flake.nix\" could not be found!"
fi

if [ ! -z "$OPEN_EDITOR" ]; then
    "$EDITOR" ""$DOTFILES_DIR"/flake.nix"
    exit 0
fi

if [ -z "$DONT_UPDATE" ]; then
    pushd "$DOTFILES_DIR" 1>/dev/null
    runColored "nix flake update"
    popd 1>/dev/null
fi

rebuild_cmd="sudo nixos-rebuild switch --impure"

if [ ! -z "$FAST_REBUILD" ]; then
    rebuild_cmd+=" --fast"
fi

runColored "$rebuild_cmd"

[[ -z "$DONT_COLLECT_GARBAGE" ]] && runColored "nix-collect-garbage"
