#!/bin/bash

IFS=$'\n'
cdesk=""
active_win=""
update_tasks="0" # only used by get_task
old_active_win=""
declare -a task_hexs=()
declare -a task_wins=()
declare -a task_desk=()
declare -a count=( "0" "0" "0" "0" "0" "0" "0" "0" "0" )

update_information() {
	active_win="$(pfw)"
	if [ "$active_win" != "$old_active_win" ]; then
		# Assumes the only updates will occur if the focused window changes
		# this assumption saves a little bit of computation in the long run
		task_hexs=()
		task_wins=()
		task_desk=()
		count=( "0" "0" "0" "0" "0" "0" "0" "0" "0" )
		win_list="$(wmctrl -l)"
		win_list="${win_list//$(uname -n)/}"
		for line in $win_list; do
			tmp="${line:0:10}"
			line="${line:12}"
			win_desk="${line%% *}"
			count["$win_desk"]="$((${count[$win_desk]} + 1))"
			task_hexs+=( "$tmp" )
			win_name="${line#$win_desk*}"
			if [ "$tmp" = "$active_win" ]; then
				cdesk="$win_desk"
			fi
			task_desk+=( "$win_desk" )
			task_wins+=( "${win_name:2}" )
		done
		if [ "${active_win:0:7}" = "0x00000" ] || [ "$active_win" = "0x0" ]; then
			cdesk="$(wmctrl -d)"
			cdesk="${cdesk%*  \* *}"
			cdesk="${cdesk: -1}"
			old_active_win=""
			tasks_string=""
		else
			old_active_win="$active_win"
			update_tasks="1"
		fi
	fi
}
