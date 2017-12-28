#!/bin/bash

# This plugin depends on my get_info plugin

max_length="70"
format_len="1"

format_tasks_string() {
	if [ "$update_tasks" -eq "1" ]; then
		tasks_string=""
		win_len="${count[$cdesk]}"
		if [ "$win_len" -gt "0" ]; then
			win_len="$[ $max_length / $win_len ]"
		else
			win_len="0"
		fi
		for i in `seq 0 ${#task_hexs[@]}`; do
			hex_i="${task_hexs[$i]}"
			win_i="${task_wins[$i]}"
			if [ "${task_desk[$i]}" = "$cdesk" ]; then
				name_len="$[ ${#win_i} + $format_len ]"
				if [ "$name_len" -lt "$win_len" ]; then
					spacer=""
					spacer_len="$[ $win_len - $name_len - $format_len ]"
					for i in `seq 0 $spacer_len`; do
						spacer+=" "
					done
					# Feel free to change any following additions to the tasks_string variable
					# win_i is the current window name (what will show in the task bar)
					# hex_i is the current window's hex value
					if [ "$active_win" = "$hex_i" ]; then
						tasks_string+="%{R} $win_i$spacer%{R}"
					else
						tasks_string+=" $win_i$spacer"
					fi
				else
					if [ "$active_win" = "$hex_i" ]; then
						tasks_string+="%{R} ${win_i:0:$win_len}$spacer%{R}"
					else
						tasks_string+=" ${win_i:0:$win_len}"
					fi
				fi
			fi
		done
		echo "$tasks_string"
		update_tasks="0"
	fi
}

