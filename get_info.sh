#!/bin/bash

update_information() {
	active_win="$(pfw)"
	if [ "$active_win" != "$old_active_win" ]; then
		update_tasks="1"
		if [ "$active_win" = "0x000000d7" ]; then
			cdesk="$(wmctrl -d)"
			cdesk="${cdesk%*  \* *}"
			cdesk="${cdesk: -1}"
		else
			# Initialisations
			declare -a task_hexs=()
			declare -a task_wins=()
			declare -a task_desk=()
			declare -a count=( "0" "0" "0" "0" "0" "0" "0" "0" "0" )
			win_list="$(wmctrl -l)"
			win_list="${win_list//$(uname -n)/}"
			old_active_win="$active_win"
			for line in $win_list; do
				tmp="${line:0:10}"
				line="${line:12}"
				win_desk="${line%% *}"
				count["$win_desk"]="$[ ${count[$win_desk]} + 1 ]"
				task_hexs+=( "$tmp" )
				win_name="${line#$win_desk*}"
				if [ "$tmp" = "$active_win" ]; then
					cdesk="$win_desk"
				fi
				task_desk+=( "$win_desk" )
				task_wins+=( "${win_name:2}" )
			done
			# condense count, fix this for >9 desktops later
			used_desks=""
			for i in `seq 0 $desk_range`; do
				if [ "${count[$i]}" -gt "0" ]; then
					used_desks+="1"
				else
					used_desks+="0"
				fi
			done
		fi
	fi
}
