#!/bin/bash

active_win="$(pfw)"
if [ "$active_win" != "$old_active_win" ]; then
	# [0]=task bar length in characters (default=100)
	# [1]=active window background colour (%{B#545454})
	# [2]=offset for any customisations aesthetically in characters (0)
	declare -a consts=( "100" "%{B#545454}" "0" )
	# Initialisations
	declare -a task_hexs=()
	declare -a task_wins=()
	declare -a task_desk=()
	declare -a count=( "0" "0" "0" "0" "0" "0" "0" "0" "0" )
	win_list="$(wmctrl -l)"
	win_list="${win_list//$(uname -n)/}"
	old_active_win="$active_win"
	win_len="0"
	tasks=""
	IFS=$'\n'
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
	win_len="${count[$cdesk]}"
	if [ "$win_len" -gt "0" ]; then
		win_len="$[ ${consts[0]} / $win_len ]"
	else
		win_len="0"
	fi
	for i in `seq 0 ${#task_hexs[@]}`; do
		hex_i="${task_hexs[$i]}"
		win_i="${task_wins[$i]}"
		if [ "${task_desk[$i]}" = "$cdesk" ]; then
			name_len="$[ ${#win_i} + ${consts[2]} ]"
			if [ "$name_len" -lt "$win_len" ]; then
				spacer=""
				spacer_len="$[ $win_len - $name_len - ${consts[2]} ]"
				for i in `seq 0 $spacer_len`; do
					spacer+=" "
				done
				# Feel free to change any following additions to the tasks variable
				# win_i is the current window name (what will show in the task bar)
				# hex_i is the current window's hex value
				if [ "$active_win" = "$hex_i" ]; then
					tasks+=" ${consts[1]}"
					tasks+="$win_i$spacer%{B-}"
				else
					tasks+=" $win_i$spacer"
				fi
			else
				if [ "$active_win" = "$hex_i" ]; then
					tasks+=" ${consts[1]}"
					tasks+="${win_i:0:$win_len}$spacer%{B-}"
				else
					tasks+=" ${win_i:0:$win_len}"
				fi
			fi
		fi
	done
	echo "$tasks"
fi

