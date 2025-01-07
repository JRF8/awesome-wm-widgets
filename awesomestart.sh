#!/bin/bash

picom &
setxkbmap -option caps:escape
nitrogen --restore &

if [ -f /usr/bin/gentoo-pipewire-launcher ]; then
	gentoo-pipewire-launcher &
fi

udiskie &
