# A function to automatically cd to the directory a file is located in
# This is meant to be sourced instead of executed

function cd() {
    if [ -f "$1" ]; then
        builtin cd "$(dirname "$1")"
        return
    fi

    builtin cd $@
}
