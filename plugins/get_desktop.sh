#!/bin/bash

# This plugin depends on my get_info plugin
# count[],cdesk from get_info.sh
#cdm1=$((cdesk - 1))
#cdp1=$((cdesk + 1))
icon=""
#desktop_string=""

# desk_range is the number of desktops you have, minus one
desk_range="8"

insert_icon() {
	if [ "${count[$1]}" -gt "0" ]; then
		# Icon used to indicate open windows
#		echo " x "
		icon=" x "
	else
		# Icon for an empty desktop
#		echo " o "
		icon=" o "
	fi
}

update_desktop() {
	desktop_string=""
	for i in $(seq 0 $((cdesk - 1))); do
		insert_icon $i
#		desktop_string+="$(insert_icon $i)"
		desktop_string+="$icon"
	done
	insert_icon $cdesk
#	desktop_string+="%{R}$(insert_icon $cdesk)%{R}"
	desktop_string+="%{R}$icon%{R}"
	for i in $(seq $((cdesk + 1)) $desk_range); do
		insert_icon $i
#		desktop_string+="$(insert_icon $i)"
		desktop_string+="$icon"
	done
#	u="$desktop_string"
#	echo "$desktop_string"
}
