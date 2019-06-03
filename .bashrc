# aliases
alias files="nautilus"
alias cls="clear"
alias unmount="umount"

# exports
export VISUAL=vim
export EDITOR="$VISUAL"

# path additions
export PATH="$PATH:/home/ivar/.net/"

# enable powerline-shell
function _update_ps1() {
	PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
