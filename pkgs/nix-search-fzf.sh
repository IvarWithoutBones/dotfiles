
#!@runtimeShell@

# An fzf script with autocomplete from "nix search" which allows for interactive fuzzy searching of derivations.
# After the search a nix subcommand is executed on the selected derivation(s), e.g. "nix shell" or "nix run".

set -eou pipefail
PATH="$PATH:@binPath@"

FLAKE="nixpkgs" # The default flake to use. TODO: make this configurable
NIX_SUBCOMMAND="shell" # The default nix subcommand to execute
MULTIPLE_SELECTION=true # Wether to allow the user to select multiple derivations

if ! [ -z "${XDG_CACHE_HOME-}" ]; then
  CACHE_PATH="$XDG_CACHE_HOME/nix-search-fzf/cache.txt"
else
  CACHE_PATH="$HOME/.cache/nix-search-fzf/cache.txt"
fi

handleArguments() {
    while (( "$#" > 0 )); do
        case "$1" in
            -s|shell|--shell)
                NIX_SUBCOMMAND="shell" ;;
            -b|build|--build)
                NIX_SUBCOMMAND="build" ;;
            -r|run|--run)
                NIX_SUBCOMMAND="run"
                MULTIPLE_SELECTION=false ;;
            -e|edit|--edit)
                NIX_SUBCOMMAND="edit"
                MULTIPLE_SELECTION=false ;;
            -u|update|--update)
                manageCache true
                exit ;;
            -h|help|--help)
                echo "Usage: $(basename "$0") [--shell|--build|--run|--edit|--update]"
                echo "  --shell: enter a nix shell with the selected package(s). This is the default"
                echo "  --build: build the selected package(s) with nix build"
                echo "  --run: run the selected package with nix run"
                echo "  --edit: edit the selected package with nix edit"
                echo "  --update: update the nix search cache, this is done automatically every 10 days"
                echo "  --help: show this help message"
                exit 0 ;;
            *)
                echo "Unknown option '$1'"
                exit 1 ;;
        esac
        shift 1
    done
}

runColored() {
    printf "\e[32m\$ %s\n\e[0m" "$1"
    eval $1
}

manageCache() {
    update() {
        echo "caching attribute paths..."
        # Create a list of all attribute paths with "legacyPackages.$arch" stripped
        # In the future this could contain metadata as well, doing a "nix-eval" for each isnt the fastest
        nix search ${FLAKE} --json | jq -r 'keys[]' | cut -d'.' -f3- > ${CACHE_PATH}
        echo "succesfully cached the attribute paths"
    }

    mkdir -p $(dirname ${CACHE_PATH})
    if [[ ! -f "${CACHE_PATH}" || $# -eq 1 ]]; then
        update
    elif [[ "$(date -r ${CACHE_PATH} +%s)" -lt "$(date -d "now - 10 days" +%s)" ]]; then
        echo "cache file is older than 10 days, automatically updating the cache"
        update
    fi
}

# The preview inside of fzf containing some metadata. Note that this must be self-contained as it gets executed in a subshell.
previewText() {
    local PKG_NAME="$1"
    local FLAKE="$2"
    local FLAKE_PATH="${FLAKE}#${PKG_NAME}"

    removeQuotes() {
        local FLAG="$@"
        FLAG="${FLAG%\"}"
        echo "${FLAG#\"}"
    }

    newlinesToCommaSeperated() {
        echo $@ | sed ':a;N;$!ba;s/\n/, /g'
    }

    evalAttr() {
        local ATTR="$1"
        local DATA="$(nix eval "$FLAKE_PATH".$ATTR 2>/dev/null)"
        [[ "${DATA}" != "null" && "${DATA}" != "false" && ! -z "$DATA" ]] && echo "$(removeQuotes ${DATA})"
    }

    evalJsonAttr() {
        local ATTR="$1"
        local JQ_ARGS="$2"
        local DATA="$(nix eval --json "$FLAKE_PATH".$ATTR 2>/dev/null | jq -r "$JQ_ARGS")"
        [[ "${DATA}" != "null" && ! -z "$DATA" ]] && echo "${DATA}"
    }

    evalNixpkgsLib() {
        local FUNCTION="$1"
        # TODO: dont import nixpkgs with IFD. This could also mismatch iwth the flake
        local DATA="$(nix eval --raw --expr "with import <nixpkgs> {}; lib.${FUNCTION} pkgs.${PKG_NAME}" 2>/dev/null)"
        [[ "${DATA}" != "null" && ! -z "$DATA" ]] && echo "${DATA}"
    }

    [[ ! -z "$(evalAttr "meta.broken")" ]] && echo "broken: true"
    [[ ! -z "$(evalAttr "meta.insecure")" ]] && echo "insecure: true"

    local version="$(evalAttr "version")"
    [[ -z "$version" ]] && version="$(evalNixpkgsLib "getVersion")" # Derive it from "name" with getVersion as a backup
    ! [[ -z "$version" ]] && echo "version: $version"

    local homepage="$(evalAttr "meta.homepage")"
    ! [[ -z "$homepage" ]] && echo "homepage: $homepage"

    local description="$(evalAttr "meta.description")"
    ! [[ -z "$description" ]] && echo "description: $description"

    local license="$(evalJsonAttr "meta.license" 'if type=="array" then .[].fullName else .fullName end')"
    ! [[ -z "$license" ]] && echo "license: $(newlinesToCommaSeperated $license)"

    local maintainers="$(evalJsonAttr "meta.maintainers" '.[].github')"
    ! [[ -z "$maintainers" ]] && echo "maintainers: $(newlinesToCommaSeperated $maintainers)"

    local platforms="$(evalJsonAttr "meta.platforms" 'if type=="array" then .[] else . end')"
    ! [[ -z "$platforms" ]] && echo "platforms: $(newlinesToCommaSeperated $platforms)"
}

runFzf() {
    export -f previewText
    if [[ "$MULTIPLE_SELECTION" == true ]]; then
        MULTI_CMD="--multi"
    else
        MULTI_CMD="--no-multi"
    fi

    cat ${CACHE_PATH} | fzf \
        "${MULTI_CMD}" \
        --height=40% \
        --prompt="${NIX_SUBCOMMAND} > " \
        --preview-window=right,70% \
        --border rounded \
        --preview "bash -c \"previewText {} ${FLAKE}\""
}

runNix() {
    declare -a SELECTED_PKGS=($@)
    [[ ${#SELECTED_PKGS[@]} -eq 0 ]] && exit 0

    # Build a brace expansion string if multiple packages are selected
    if [[ "${MULTIPLE_SELECTION}" && "${#SELECTED_PKGS[@]}" -gt 1 ]]; then
        local pkg_list="{"
        for pkg in ${SELECTED_PKGS[@]}; do
            pkg_list+="${pkg},"
        done
        SELECTED_PKGS="${pkg_list%,}}"
    fi

    runColored "NIXPKGS_ALLOW_UNFREE=1 nix ${NIX_SUBCOMMAND} ${FLAKE}#${SELECTED_PKGS} --impure"
}

handleArguments $@
manageCache
runNix "$(runFzf)"
