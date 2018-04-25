#!/bin/bash

# This plugin depends on my get_info plugin

icon_used="x"
icon_empty="o"
# desk_range is the number of desktops you have, minus one
desk_range="8"

insert_icon() {
	if [ "${count[$1]}" -gt "0" ]; then
		echo "$icon_used"
	else
		echo "$icon_empty"
	fi
}

update_desktop() {
	desktop_string=""
	# expand used_desks
	for i in `seq 0 $[ $cdesk - 1 ]`; do
		desktop_string+=" $(insert_icon $i) "
	done
	desktop_string+="%{R} $(insert_icon $cdesk) %{R}"
	for i in `seq $[ $cdesk + 1 ] $desk_range`; do
		desktop_string+=" $(insert_icon $i) "
	done
	echo -e "$desktop_string"
}
