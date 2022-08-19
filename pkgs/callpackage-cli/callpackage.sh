#! /usr/bin/env bash

# A shortcut to callPackage from the command line

set -euo pipefail

path="${1-default.nix}"
attr="callPackage"

while (( $# > 0 )); do
    case "$1" in
        --attr)
            attr="$2"
            shift
            ;;
        -h|--help)
            echo "usage: callpackage <path to derivation> [--attr ('callPackage')]"
            exit
            ;;
    esac
    shift
done

nix build --print-build-logs --impure --expr "((import <nixpkgs> {}).$attr (import $(realpath "$path")) { })"
