#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash

set -euo pipefail

PKG_NAME="$1"
FLAKE="$2"
FLAKE_PATH="${FLAKE}#${PKG_NAME}"

removeQuotes() {
    local FLAG="$*"
    FLAG="${FLAG%\"}"
    echo "${FLAG#\"}"
}

newlinesToCommaSeperated() {
    echo "$@" | sed ':a;N;$!ba;s/\n/, /g'
}

evalAttr() {
    local ATTR DATA
    ATTR="$1"
    DATA="$(nix eval "$FLAKE_PATH"."$ATTR" 2>/dev/null)"
    [[ "${DATA}" != "null" && "${DATA}" != "false" && -n "$DATA" ]] && removeQuotes "$DATA"
}

evalJsonAttr() {
    local ATTR JQ_ARGS DATA
    ATTR="$1"
    JQ_ARGS="$2"
    DATA="$(nix eval --json "$FLAKE_PATH"."$ATTR" 2>/dev/null | jq -r "$JQ_ARGS")"
    [[ "$DATA" != "null" && -n "$DATA" ]] && echo "$DATA"
}

evalNixpkgsLib() {
    local FUNCTION DATA
    FUNCTION="$1"
    # TODO: dont import nixpkgs with IFD. This could also mismatch iwth the flake
    DATA="$(nix eval --raw --expr "with import <nixpkgs> {}; lib.${FUNCTION} pkgs.${PKG_NAME}" 2>/dev/null)"
    [[ "${DATA}" != "null" && -n "$DATA" ]] && echo "${DATA}"
}

[[ -n "$(evalAttr "meta.broken")" ]] && echo "broken: true"
[[ -n "$(evalAttr "meta.insecure")" ]] && echo "insecure: true"

version="$(evalAttr "version")"
[[ -z "$version" ]] && version="$(evalNixpkgsLib "getVersion")" # Derive it from "name" with getVersion as a backup
[[ -n "$version" ]] && echo "version: $version"

homepage="$(evalAttr "meta.homepage")"
[[ -n "$homepage" ]] && echo "homepage: $homepage"

description="$(evalAttr "meta.description")"
[[ -n "$description" ]] && echo "description: $description"

license="$(evalJsonAttr "meta.license" 'if type=="array" then .[].fullName else .fullName end')"
[[ -n "$license" ]] && echo "license: $(newlinesToCommaSeperated "$license")"

maintainers="$(evalJsonAttr "meta.maintainers" '.[].github')"
[[ -n "$maintainers" ]] && echo "maintainers: $(newlinesToCommaSeperated "$maintainers")"

platforms="$(evalJsonAttr "meta.platforms" 'if type=="array" then .[] else . end')"
[[ -n "$platforms" ]] && echo "platforms: $(newlinesToCommaSeperated "$platforms")"
