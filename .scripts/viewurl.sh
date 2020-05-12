#!/bin/sh

FNAME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
feh -q $(wget -qO $FNAME $1)
rm $FNAME
