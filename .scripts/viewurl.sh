#!/bin/sh

feh -q $(wget -qO unknown $1)
rm unknown
