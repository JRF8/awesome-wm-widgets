#!/bin/bash

WALLDIR="$HOME/Pictures"
XRES="$HOME/.cache/wal/colors.Xresources"

WALL="$WALLDIR/$(ls $WALLDIR | rofi -dmenu)"

nitrogen --set-zoom-fill --save $WALL

wal -i $WALL

xrdb $XRES

echo 'awesome.restart()' | awesome-client
