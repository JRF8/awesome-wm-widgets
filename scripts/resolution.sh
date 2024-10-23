#!/bin/bash

RESDIR="$HOME/.screenlayout/"
RES=$(ls $RESDIR | rofi -dmenu)

$RESDIR/$RES

nitrogen --restore
