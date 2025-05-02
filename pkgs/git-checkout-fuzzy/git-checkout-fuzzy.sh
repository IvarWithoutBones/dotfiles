#!/usr/bin/env bash

# List all branches on a remote (`origin` by default) and checkout the one picked with fzf

set -euo pipefail

if (($# > 1)); then
    echo "usage: $0 [remote]" >&2
    exit 1
fi

# Sync the remote's branches
REMOTE="${1:-origin}"
git fetch "${REMOTE}"

# List all of the remote's branches (except for `HEAD`), sorted by the date of the last commit.
BRANCHES="$(git branch \
    --remotes "${REMOTE}" \
    --list "${REMOTE}/*" \
    --sort "-committerdate" \
    --omit-empty \
    --format "%(if:notequals=HEAD)%(refname:lstrip=3)%(then)%(refname:lstrip=3)%(end)")"
if [ -z "${BRANCHES}" ]; then
    echo "no branches found for remote '${REMOTE}'" >&2
    exit 1
fi

# Open the fuzzy picker and let the user select a branch
BRANCH="$(fzf \
    --no-sort \
    --exit-0 \
    --prompt "git checkout > " \
    --border "none" \
    --list-border "rounded" \
    --preview-window "60%,wrap" \
    --preview "git log --color=always '${REMOTE}/{}'" <<<"${BRANCHES}")"

# If any branch was selected, check it out
if [ -n "${BRANCH}" ]; then
    if [ "${REMOTE}" != "origin" ]; then
        # Branches from remotes other than origin will not be automatically tracked, so we need to be more explicit.
        BRANCH="${REMOTE}/${BRANCH}"
    fi

    git checkout "${BRANCH}"
fi
