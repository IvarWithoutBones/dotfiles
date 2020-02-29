function echo_green {
	tput setaf 2
	echo $1
	tput sgr0
}

echo_green "nix-channel --update"
nix-channel --update
echo_green "home-manager switch --keep-going"
home-manager switch --keep-going
echo_green "sudo nixos-rebuild switch --upgrade"
sudo nixos-rebuild switch --upgrade
echo_green "nix-env -if ~/.scripts/python.nix"
nix-env -if ~/.scripts/python.nix

if [ "$1" != "-n" ]; then # The N stands for no, trust me it makes sense
	echo_green "nix-collect-garbage"
	nix-collect-garbage; fi
