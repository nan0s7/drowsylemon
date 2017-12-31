#!/bin/bash

# This plugin depends on my get_info plugin

icon_used="x"
icon_empty="o"
# desk_range is the number of desktops you have, minus one
desk_range="8"

update_desktop() {
	result=""
	# expand used_desks
	for i in `seq 0 $desk_range`; do
		if [ "${count[$i]}" -gt "0" ]; then
			icon="$icon_used"
		else
			icon="$icon_empty"
		fi
		if [ "$i" -eq "$cdesk" ]; then
			desktop_string+="%{R} $icon %{R}"
		else
			desktop_string+=" $icon "
		fi
	done
	echo -e "$desktop_string"
}
