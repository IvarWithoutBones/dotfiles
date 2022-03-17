#!@runtimeShell@

# TODO: should probably rewrite this in python

set -e

export PATH="$PATH:@binPath@"

GITHUB_NAME="IvarWithoutBones"

error() {
    printf "\e[1;31merror:\e[0m %s\n" "$1"
    exit 1
}

while (( "$#" > 0 )); do
    case "$1" in
        -n|new|--new)
            NEW_PKG=1 ;;
        -o|old|--old)
            UPDATED_PKG=1 ;;
        -h|help|--help)
            echo "Usage: $(basename "$0") [-n] [-o] attribute"
            echo "  -n: new package"
            echo "  -o: updated package"
            echo "  -h: show this message"
            exit 0 ;;
        *)
            ATTR="$1" ;;
    esac
    shift 1
done

if [[ ! $OLD_PKG && ! $UPDATED_PKG ]]; then
    UPDATED_PKG=1
elif [[ $OLD_PKG && $UPDATED_PKG ]]; then
    error "Options -n and -o are mutually exclusive!"
fi

if [ -z "${ATTR}" ]; then
    error "No attribute was specified!"
fi

NIXPKGS_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || error "not in a git tree!"
if [ ! -f "${NIXPKGS_ROOT}/default.nix" ]; then
    error "could not locate nixpkgs default.nix"
fi

getMetaAttr() {
    jq -r ".$@" <<< "${PKG_META}"
}

getName() {
    nix eval --impure --raw --expr "
      let
        lib = (import ${NIXPKGS_ROOT} { }).lib;
      in lib.getName \"$@\"
    "
}

getPackage() {
    PKG_META="$(nix eval -f "${NIXPKGS_ROOT}" --json "$1".meta)"

    PKG_NAME="$(getName "$(getMetaAttr "name")")"
    PKG_DESCRIPTION="$(getMetaAttr "description")"
    PKG_HOMEPAGE="$(getMetaAttr "homepage")"
    PKG_CHANGELOG="$(getMetaAttr "changelog")"
    PKG_MAINTAINERS=($(getMetaAttr "maintainers[] | .github"))
}

pingMaintainers() {
    DESCRIPTION=""

    if (( "${#PKG_MAINTAINERS[@]}" > 0 )); then
        MAINTAINERS=""

        for maintainer in "${PKG_MAINTAINERS[@]}"; do
            [[ "${maintainer}" = "$GITHUB_NAME" ]] && continue

            MAINTAINERS+=" @${maintainer}"
        done
    
        if [ "${MAINTAINERS-}" ]; then
            DESCRIPTION+="cc${MAINTAINERS}"
        fi
    fi

    echo "${DESCRIPTION}"
}

newPkgDescription() {
    DESCRIPTION="This adds [${PKG_NAME}](${PKG_HOMEPAGE}), "
    FIRST_WORD="${PKG_DESCRIPTION%% *}"

    case "${FIRST_WORD,,}" in
        the|an|a)
            ;;
        *)
            DESCRIPTION+="an " ;;
    esac

    if [[ "${FIRST_WORD}" =~ ^[[:upper:]]+$ && "${#FIRST_WORD}" -gt 1 ]]; then
        # If the entire word is capitalised use it as is
        DESCRIPTION+="${PKG_DESCRIPTION}."
    else
        # Alternatively remove capitalisation
        DESCRIPTION+="${PKG_DESCRIPTION,}."
    fi

    if [ "$(pingMaintainers)" ]; then
        DESCRIPTION+="\n\n$(pingMaintainers)"
    fi

    echo "${DESCRIPTION}"
}

updatedPkgDescription() {
    DESCRIPTION=""

    if [[ ! "${PKG_CHANGELOG}" = "null" ]]; then
        DESCRIPTION+="See [the changelog](${PKG_CHANGELOG}) for more information."
        shouldAddNewlines=1
    fi

    if [ "$(pingMaintainers)" ]; then
        [ "${shouldAddNewlines}" ] && DESCRIPTION+="\n\n"
        DESCRIPTION+="$(pingMaintainers)"
    fi

    echo "${DESCRIPTION}"
}

generatePullRequestTemplate() {
    tmpdir="$(mktemp -d /tmp/nixpkgs-pr.XXX)"
    trap "rm -rf ${tmpdir}" EXIT

    echo "Fetching pull request template..."
    curl https://raw.githubusercontent.com/NixOS/nixpkgs/master/.github/PULL_REQUEST_TEMPLATE.md -o "${tmpdir}/pr-template.md"

    # Remove comments
    pandoc --wrap=preserve --tab-stop 2 --to gfm --strip-comments "${tmpdir}/pr-template.md" --output "${tmpdir}/patched-pr-template.md"

    # TODO: figure out target automatically
    if [ "${NEW_PKG}" ]; then
        TARGET_DESCRIPTION="$(newPkgDescription)"
    elif [ "${UPDATED_PKG}" ]; then
        TARGET_DESCRIPTION="$(updatedPkgDescription)"
    fi

    # Insert our generated description
    if [ "${TARGET_DESCRIPTION}" ]; then
        sed -ie "/^###### Description of changes/a ${TARGET_DESCRIPTION}" "${tmpdir}/patched-pr-template.md"
    fi

    # Check "Fits CONTRIBUTING.md" automatically, i wouldn't open a PR otherwise
    sed -ie "s/\[ \] Fits \[CONTRIBUTING.md\]/\[X\] Fits \[CONTRIBUTING.md\]/g" "${tmpdir}/patched-pr-template.md"

    echo "Succesfully patched the description"
}

encodeAndOpenUrl() {
    GIT_BRANCH="$(git branch --show-current)"
    BODY="$(cat "${tmpdir}/patched-pr-template.md" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))")"
    URL="https://github.com/NixOS/nixpkgs/compare/master...${GITHUB_NAME}:${GIT_BRANCH}?quick_pull=1&body=${BODY}"
    
    echo "Launching browser..."
    xdg-open "$URL" &>/dev/null
}

getPackage "$ATTR"
generatePullRequestTemplate
encodeAndOpenUrl
