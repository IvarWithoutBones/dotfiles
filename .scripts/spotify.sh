#!/bin/sh

PID=$(pgrep tizonia)
DEFAULT="shit. 3"

if [ $PID ] 
then
	kill $PID
	echo "Killed tizonia instance"
else
	SONG=$(echo $DEFAULT | dmenu -p "What playlist would you like to listen to?")
	tizonia -s --spotify-playlist "$SONG" >/dev/null 2>&1
fi
