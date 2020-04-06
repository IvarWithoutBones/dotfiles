function do_but_green {
	tput setaf 2
	echo $1
	tput sgr0
	$1
}

do_but_green "nix-channel --update"
do_but_green "home-manager switch --keep-going"
do_but_green "sudo nixos-rebuild switch --upgrade"
do_but_green "nix-collect-garbage"

if [ "$1" == "-f" ]; then # In case you really wanna save some space
	do_but_green "nix-store -v --optimise"
fi
