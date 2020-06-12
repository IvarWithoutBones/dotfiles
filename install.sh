#!/bin/sh

function do_but_green {
        tput setaf 2
        echo \$ $1
        tput sgr0
        $1
}

MACHINE=	# Set this to either "pc" or "laptop"

# Failchecks
if [ -z "$MACHINE" ]; then
	echo "No machine was selected"
	exit
elif [ ! -d "$(pwd)/$MACHINE" ]; then
	echo "$(pwd)/$MACHINE does not exist"
	exit
fi

do_but_green "mkdir -p /home/ivar/.config"
do_but_green "cp -vrfL $(pwd)/$MACHINE/config/* /home/ivar/.config/"
do_but_green "mkdir -p /home/ivar/.scripts"
do_but_green "cp -vrfL $(pwd)/$MACHINE/scripts/* /home/ivar/.scripts/"
do_but_green "sudo cp -vfL $(pwd)/$MACHINE/configuration.nix /etc/nixos/configuration.nix"
