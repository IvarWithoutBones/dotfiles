# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Path additions
path+=/opt/minecraft/minecraft-launcher
path+=/home/ivar/.local/bin

# Exports
export VISUAL=vim
export EDITOR="$VISUAL"

# Aliases
alias ls="ls --color=auto"
alias la="ls --color=auto -A"
alias speedtest="printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && speedtest | grep -E 'Download|Upload'"
alias mp3="mpv --no-video"
alias watch="watch -n0 -c"
alias sm64="retroarch-mupen64plus '/home/ivar/misc/roms/N64/Super Mario 64 (Japan).z64'"
alias sm64-60fps="retroarch-mupen64plus '/mnt/hdd/roms/N64/SM64 60fps V2.z64'"
alias class="xprop | grep WM_CLASS"
alias killdiscord="pkill Discord && pkill Discord" # For some reason you need to kill it twice?
alias viewurl="/home/ivar/.scripts/viewurl.sh"

eval $(thefuck --alias)
source /home/ivar/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
