#!/bin/sh

# This is purely because I'm too lazy to manually type this out.
# This normally does not warrent a script, however my laziness won today.

git update-index --assume-unchanged install.sh # This is always different, so we ignore it.
git pull
./install.sh
./common/scripts/update-system.sh
