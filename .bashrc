export PATH=$PATH:/opt/minecraft/minecraft-launcher
export VISUAL=vim
export EDITOR="$VISUAL"

alias la="ls -A"
alias filesize="du -sh"
alias lsblk="lsblk | grep -v snap"
alias n64="mupen64plus"
alias speedtest="printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && speedtest | grep -E 'Download|Upload'"
alias mp3="mpv --no-video"
alias wine="wine64"
alias watch="watch -n0 -c"
alias sm64="mupen64plus '/home/ivar/misc/hdd/roms/N64/Super Mario 64 (Japan).z64'"

source /usr/share/defaults/etc/profile

export PATH="$PATH:/home/ivar/.net"
