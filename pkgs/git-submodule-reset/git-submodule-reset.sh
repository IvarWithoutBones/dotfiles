#!/usr/bin/env bash

# Reset git submodules to their state in the containing project's last commit.
# Usage: git-submodule-reset.sh [<path>...]

set -euo pipefail

submodulePaths=()
for path in "$@"; do
    : "${submodulePaths:="--"}"
    # Allow relative paths when executing this script from a Git alias.
    submodulePaths+=("$(realpath "${GIT_PREFIX:-}${path}")")
done

# Re-initializing seems to be the most reliable way to reset submodules, regardless of their current state.
git submodule deinit --force "${submodulePaths[@]:-"--all"}"
git submodule update --init --checkout --recursive "${submodulePaths[@]}"
