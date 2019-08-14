export PATH=$PATH:/opt/minecraft/minecraft-launcher
export VISUAL=vim
export EDITOR="$VISUAL"

alias la="ls -A"
alias lsblk="lsblk | grep -v snap"
alias n64="mupen64plus"
alias speedtest="printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && speedtest | grep -E 'Download|Upload'"

source /usr/share/defaults/etc/profile

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
