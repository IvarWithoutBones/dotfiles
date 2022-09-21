# Automatically open a PR to nixpkgs, and ping maintainers of the modified package.

set -euo pipefail

# TODO: make this configurable
GITHUB_NAME="IvarWithoutBones"

error() {
    printf "\e[1;31merror:\e[0m %s\n" "$1"
    exit 1
}

pingMaintainers() {
    local -r maintainers=($@)
    local text maintainerList

    if (( "${#maintainers[@]}" > 0 )); then
        for maintainer in "${maintainers[@]}"; do
            [[ "$maintainer" == "$GITHUB_NAME" ]] && continue
            maintainerList+=" @$maintainer"
        done

        if [ "${maintainerList-}" ]; then
            text+="cc${maintainerList}"
        fi
    fi

    echo "${text-}"
}

newPackageDescription() {
    local -r name="$1" meta="$2"
    local -r description="$(jq -r ".description" <<< "$meta")"
    local -r homepage="$(jq -r ".homepage" <<< "$meta")"
    local text="This adds [$name]($homepage), "

    # Make sure the beginning of the sentence makes sense
    local -r firstWord="${description%% *}"
    case "${firstWord,,}" in
        the|an|a)
            ;;
        *)
            text+="an " ;;
    esac

    if [[ "$firstWord" =~ ^[[:upper:]]+$ ]] && (( "${#firstWord}" > 1 )); then
        # If the entire word is capitalised use it as is
        text+="$description."
    else
        # Alternatively remove capitalisation
        text+="${description,}."
    fi

    echo "${text-}"
}

generatePullRequestTemplate() {
    local -r nixpkgsRoot="$1" attr="$2" operation="$3"
    local -r tmpDir="$(mktemp -td "nixpkgs-pr.XXXXXX")"
    local -r meta="$(nix --extra-experimental-features nix-command eval -f "$nixpkgsRoot" --json "$attr".meta)"
    local prDescription shouldAddNewlines

    # Fetch the upstream pull request template and remove the comments
    curl -ns "https://raw.githubusercontent.com/NixOS/nixpkgs/master/.github/PULL_REQUEST_TEMPLATE.md" -o "$tmpDir/pr-template.md"
    pandoc --wrap=preserve --tab-stop 2 --to gfm --strip-comments "$tmpDir/pr-template.md" --output "$tmpDir/patched-pr-template.md"

    # Generate the actual description for the PR
    if [[ "$operation" == "new" ]]; then
        # We want to use `lib.getName` instead of `pname` for compatibility, not all derivations provide `pname`.
        local name="$(nix --extra-experimental-features nix-command eval -f "$nixpkgsRoot" --raw "$attr".name)"
        name="$(nix --extra-experimental-features nix-command eval --impure --raw --expr "
            (import $nixpkgsRoot { }).lib.getName \"$name\"
        ")"

        prDescription+="$(newPackageDescription "$name" "$meta")"
        shouldAddNewlines=1
    elif [[ "$operation" == "old" ]]; then
        local changelog="$(jq -r ".changelog" <<< "$meta")"
        # Add a link to the changelog, if present
        if [[ "${changelog}" != "null" ]]; then
            prDescription+="See [the changelog]($changelog) for more information."
            shouldAddNewlines=1
        fi
    fi

    # Ping the maintainers of the package
    local -r maintainers="$(pingMaintainers $(jq -r ".maintainers[] | .github" <<< "$meta"))"
    if [ -n "$maintainers" ]; then
        # Insert newlines if we already generated any text prior to this
        [ -n "${shouldAddNewlines-}" ] && prDescription+="\n\n"
        prDescription+="$maintainers"
    fi

    # Insert our generated description
    if [ -n "$prDescription-" ]; then
        sed -ie "/^###### Description of changes/a $prDescription" "$tmpDir/patched-pr-template.md"
    fi

    # Check "Fits CONTRIBUTING.md" automatically, i wouldn't open a PR otherwise
    sed -ie "s/\[ \] Fits \[CONTRIBUTING.md\]/\[X\] Fits \[CONTRIBUTING.md\]/g" "$tmpDir/patched-pr-template.md"
    echo "$tmpDir/patched-pr-template.md"
}

encodeUrl() {
    local -r template="$1"
    local gitBranch body url
    gitBranch="$(git branch --show-current)"
    body="$(cat "$template" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))")"
    echo "https://github.com/NixOS/nixpkgs/compare/master...${GITHUB_NAME}:$gitBranch?quick_pull=1&body=$body"
}

main() {
    local operation attr nixpkgsRoot

    # Parse shell arguments
    while (( "$#" > 0 )); do
        case "$1" in
            -n|new|--new)
                test -n "${operation-}" && error "options -n and -o are mutually exclusive!"
                operation="new"
                attr="$2"
                shift 2
                ;;
            -o|old|--old)
                test -n "${operation-}" && error "options -n and -o are mutually exclusive!"
                operation="old"
                attr="$2"
                shift 2
                ;;
            -h|help|--help)
                echo "Usage: $(basename "$0") [-h,help] [-n,new] [-o,old] <attribute>"
                echo "    new           generate a description for a new package"
                echo "    old           generate a description for a existing package"
                echo "    attribute     the attribute path of the package to generate a description for"
                echo "    help          show this message"
                exit
                ;;
            *)
                if [ -z "${attr-}" ]; then
                    attr="$1"
                    shift
                else
                    error "unknown argument $1"
                fi
                ;;
        esac
    done

    test -z "${attr-}" && error "No attribute was specified!"
    local -r nixpkgsRoot="$(git rev-parse --show-toplevel 2>/dev/null)" || error "not in a git tree!"
    test -f "$nixpkgsRoot/default.nix" || error "could not locate nixpkgs root"

    # Generate the PR body with a description based on the modified package
    echo "fetching pull request template"
    template="$(generatePullRequestTemplate "$nixpkgsRoot" "$attr" "${operation:-old}")"
    trap 'rm -rf "$(dirname "$template")"' EXIT INT TERM
    echo "succesfully fetched the template and generated a description"

    # Finally open the browser with the generated description
    echo "opening the pull request page in your browser"
    xdg-open "$(encodeUrl "$template")" &>/dev/null
}

main $@
