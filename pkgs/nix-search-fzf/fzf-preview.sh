#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash

set -euo pipefail

PKG_NAME="$1"
FLAKE="$2"
FLAKE_PATH="${FLAKE}#${PKG_NAME}"

removeQuotes() {
	local flag="$*"
	flag="${flag%\"}"
	echo "${flag#\"}"
}

newlinesToCommaSeperated() {
	echo "$@" | sed ':a;N;$!ba;s/\n/, /g'
}

evalAttr() {
	local attr data
	attr="$1"
	data="$(nix eval "$FLAKE_PATH"."$attr" 2> /dev/null)"
	[[ $data != "null" && $data != "false" && -n $data ]] && removeQuotes "$data"
}

evalJsonAttr() {
	local attr jqArgs data
	attr="$1"
	jqArgs="$2"
	data="$(nix eval --json "$FLAKE_PATH"."$attr" 2> /dev/null | jq -r "$jqArgs")"
	[[ $data != "null" && -n $data ]] && echo "$data"
}

evalNixpkgsLib() {
	local function data
	function="$1"
    # Impure is needed to import the flake reference
	data="$(nix eval --raw --impure --expr "let pkgs = (builtins.getFlake \"flake:$FLAKE\"); in pkgs.lib.$function pkgs.$PKG_NAME" 2> /dev/null)"
	[[ $data != "null" && -n $data ]] && echo "$data"
}

maybeEcho() {
	local -r prefix="$1"
	local flag="$2"
	local -r commaSeperated="${3:-false}"
	[[ $commaSeperated == "true" ]] && flag="$(newlinesToCommaSeperated "$flag")"
	test -n "$flag" && echo "$prefix $flag"
}

test -n "$(evalAttr "meta.broken")" && echo "broken: true"
test -n "$(evalAttr "meta.insecure")" && echo "insecure: true"

version="$(evalAttr "version")"
# Derive the version from "name" using 'lib.getVersion' if it's not set
test -z "$version" && version="$(evalNixpkgsLib "getVersion")"
maybeEcho "version:" "$version"

homepage="$(evalAttr "meta.homepage")"
maybeEcho "homepage:" "$homepage"

description="$(evalAttr "meta.description")"
maybeEcho "description:" "$description"

license="$(evalJsonAttr "meta.license" 'if type=="array" then .[].fullName else .fullName end')"
maybeEcho "license:" "$license" true

maintainers="$(evalJsonAttr "meta.maintainers" '.[].github')"
maybeEcho "maintainers:" "$maintainers" true

platforms="$(evalJsonAttr "meta.platforms" 'if type=="array" then .[] else . end')"
maybeEcho "platforms:" "$platforms" true
