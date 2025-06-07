#!/bin/bash

picom --backend xrender &
nitrogen --restore &

if [ -f /usr/bin/gentoo-pipewire-launcher ]; then
	killall pipewire ; gentoo-pipewire-launcher &
fi

udiskie &
