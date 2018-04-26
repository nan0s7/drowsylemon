#!/bin/bash

# This plugin depends on my get_info plugin

# desk_range is the number of desktops you have, minus one
desk_range="8"

insert_icon() {
	if [ "${count[$1]}" -gt "0" ]; then
		# Icon used to indicate open windows
		echo " x "
	else
		# Icon for an empty desktop
		echo " o "
	fi
}

update_desktop() {
	for i in `seq 0 $[ $cdesk - 1 ]`; do
		desktop_string+="$(insert_icon $i)"
	done
	desktop_string+="%{R}$(insert_icon $cdesk)%{R}"
	for i in `seq $[ $cdesk + 1 ] $desk_range`; do
		desktop_string+="$(insert_icon $i)"
	done
	echo "$desktop_string"
}
