#!/bin/bash

WALCMD=".local/.pip-pkgs/bin/wal"

WALLDIR="$HOME/Pictures"
XRES="$HOME/.cache/wal/colors.Xresources"

WALL="$WALLDIR/$(ls $WALLDIR | rofi -dmenu)"

nitrogen --set-zoom-fill --save $WALL

$WALCMD -i $WALL

xrdb $XRES

echo 'awesome.restart()' | awesome-client
