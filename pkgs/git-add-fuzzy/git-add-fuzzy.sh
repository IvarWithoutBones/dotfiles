#! /usr/bin/env bash

# A wrapper around `git add` that uses fzf to select files with unstaged changes

set -euo pipefail

runColored() {
    printf "\e[32m\$ %s\n\e[0m" "$1"
    $1
}

# Sort a list of files by the date they're last modified
sortByModifiedDate() {
    local timestamp input="$1"
    declare -A paths

    while read path; do
        timestamp="$(date -d "@$(stat -c "%Y" "$path")" "+%s")"
        paths["$timestamp"]="$path"
    done < <(sort -u <<< "$input")

    for timestamp in "${!paths[@]}"; do
        echo "$timestamp"
    done | sort -rn | while read timestamp; do
        echo "${paths["$timestamp"]}"
    done
}

# Preview diff from git when available, otherwise file/directory contents
fzfPreview() {
    local gitDiff path
    path="$1"
    gitDiff="$(git diff "$path" 2> /dev/null)"

    if test -n "$gitDiff"; then
        echo "$gitDiff" | delta --color-only 2> /dev/null
    elif test -f "$path"; then
        if test -s "$path"; then
            if [[ "$(file -b --mime-type "$path")" == text/* ]]; then
                bat --number --color=always "$path"
            else
                # The --show-all flag is necessary for binary files, but messes up syntax highlighting
                bat --show-all --number --color=always "$path"
            fi
        else
            echo "$path is empty"
        fi
    elif test -d "$path"; then
        # realpath is used to get the absolute path of symlinks
        tree -C "$(realpath "$path")"
    fi
}

fzfRun() {
    export -f fzfPreview
    fzf -0 --prompt "git add > " \
        --bind 'tab:toggle-out,shift-tab:toggle-in' \
        --multi \
        --preview-window=right,70% \
        --preview='bash -c "fzfPreview {}"' | xargs
}

GIT_ROOT="$(git rev-parse --show-toplevel)" # Just in case we're not in a git repo, shows a better error message
DIFF_FILES="$(
    git diff --name-only
    git ls-files --other --exclude-standard --exclude ".*"
)"
SELECTED_FILES="$(sortByModifiedDate "$DIFF_FILES" | fzfRun)"
test -n "$SELECTED_FILES" && runColored "git add $SELECTED_FILES"
