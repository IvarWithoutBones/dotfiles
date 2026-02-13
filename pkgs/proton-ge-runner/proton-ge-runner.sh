#!/usr/bin/env bash

# A wrapper that can launch Proton GE for you, without needing Steam.

set -euo pipefail

showUsage() {
    cat << EOF >&2
usage: proton-ge-runner program.exe [args]

The virtual hard drive is stored in "\$XDG_DATA_HOME/proton-ge-runner/<program name>/compatdata".
If the PROTON_GE_RUNNER_DATA_DIR environment variable is set, it will be used instead.

A binary named proton-ge is assumed to be in PATH, and is used to run the program.
You can also specify one yourself with the PROTON_GE_BINARY environment variable.

If you want to deny the program network usage, set the PROTON_GE_RUNNER_OFFLINE environment variable to a non-zero value. This requires systemd-run.
EOF
}

dataDir() {
    local exeName="${1%.*}"
    exeName="${exeName##*/}"
    local -r dataDir="${XDG_DATA_HOME:-${HOME}/.local/share}/proton-ge-runner/${exeName}"
    mkdir -p "${dataDir}/compatdata" # proton-ge needs this directory to exist
    echo "${dataDir}"
}

maybeOffline() {
    local runCommand="$1"
    if [[ ${PROTON_GE_RUNNER_OFFLINE:-0} != 0 ]]; then
        runCommand="systemd-run --same-dir --scope --property IPAddressDeny=any --property SocketBindDeny=any ${runCommand}"
    fi
    echo "${runCommand}"
}

runProton() {
    local -r targetExe="${1:-}"
    shift || true
    if [[ -z ${targetExe} ]] || [[ ! -f ${targetExe} ]]; then
        showUsage
        exit 1
    fi

    local dataDir runCommand
    dataDir="${PROTON_GE_RUNNER_DATA_DIR:-$(dataDir "${targetExe}")}"
    runCommand="$(maybeOffline "${PROTON_GE_BINARY:-proton-ge} waitforexitandrun ${targetExe}${1+ }${*:-}")"

    set -x
    STEAM_COMPAT_CLIENT_INSTALL_PATH="${dataDir}" STEAM_COMPAT_DATA_PATH="${dataDir}/compatdata" ${runCommand}
}

runProton "$@"
