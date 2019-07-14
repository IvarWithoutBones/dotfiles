#!/bin/bash

maim /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
lock_dir=$HOME/Misc/Pictures/lock.png

if [[ -f $lock_dir ]] 
then
    # placement x/y
    PX=0
    PY=0
    # lockscreen image info
    R=$(file $lock_dir | grep -o '[0-9]* x [0-9]*')
    RX=$(echo $R | cut -d' ' -f 1)
    RY=$(echo $R | cut -d' ' -f 3)

    SR=$(xrandr --query | grep ' connected' | cut -f3 -d' ')
    for RES in $SR
    do
        # monitor position/offset
        SRX=$(echo $RES | cut -d'x' -f 1)                   # x pos
        SRY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 1)  # y pos
        SROX=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 2) # x offset
        SROY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 3) # y offset
        PX=$(($SROX + $SRX/2 - $RX/2))
        PY=$(($SROY + $SRY/2 - $RY/2))

        convert /tmp/screen.png $lock_dir -geometry +$PX+$PY -composite -matte  /tmp/screen.png
    done
fi 
i3lock -e -n -i /tmp/screen.png
