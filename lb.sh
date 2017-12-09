#!/bin/bash

# Modify these if you like
slp="1"
time_scale="59"

# Don't change these
#tmp=""
#min="0"
offset="0"
#new_per="0"
#new_desk="0"
update_now="1"

old_bar_text=""
bar_text=""

#options="$1"
minute_scaled="$[ $time_scale / $slp ]"
#declare -a cmd_arr=()

# long-term goals:
# reduce number of tasks per second
# make configuration more modular
# keep functionality while removing the information array
# (reduce computation time by a decent amount, that way)
# add in more pretty things for the default config
# redo the get_desktop function
# possibly make functions even more general so that they can be used in
# more flexible circumstances

finish() {
	unset per
	unset tmp
	unset time_scale
#	unset new_per
#	unset min
#	unset options
#	unset new_desk
	unset update_now
#	unset cur
	unset offset
#	unset wind
	unset desk
	unset slp
	unset minute_scaled
	unset task_hexs
	unset task_wins
	unset active_win
	unset old_active_win
	unset pc_name
	unset max_task_len
	unset win_list
	unset old_win_num
	unset win_num
	unset win_desk
	unset active_col
	unset not_col
	unset tasks
	unset spacer
	unset hex_i
	unset win_i
	unset win_len
	unset format_len
	unset cut_len
	unset spacer_len
	unset name_len
	unset cdo
	unset information
}
trap finish EXIT

get_battery() {
	# This command will change in the future
    echo "$(acpi --battery | cut -d, -f2)"
}

get_date() {
	echo "$(date '+%a %b %d, %H:%M')"
}

# make this better so I don't have to use xdotool
get_desktop() {
	tmp="$(wmctrl -d)"
	tmp="${tmp%*  \* *}"
	desk="${tmp: -1}"
#	update_now="1"
}

declare -a task_hexs=()
declare -a task_wins=()
declare -a information=()
pc_name="$(uname -n)"
max_task_len="100"
active_win=""
old_active_win=""
win_list=""
active_col="%{B#545454}"
not_col="%{B-}"
format_len="4"
cdo="1"

# maybe reduce array size if cdo=1 for less computation too later
get_tasks() {
	get_active_win
	if [ "$active_win" != "$old_active_win" ]; then
		win_list="$(wmctrl -l)"
		old_active_win="$active_win"
		task_hexs=()
		task_wins=()
#				if [ "$(wattr m $tmp; echo $?)" -eq "0" ]; then
		win_list="${win_list//$pc_name/}"
		IFS=$'\n'
#		if [ "$cdo" -eq "1" ]; then
		for line in $win_list; do
			task_hexs+=( "${line:0:10}" )
			line="${line:12}"
			win_desk="${line%% *}"
			win_name="${line#$win_desk*}"
			task_wins+=( "$win_desk""${win_name:2}" )
		done
		format_tasks
	fi
}

get_active_win() {
	active_win="$(pfw)"
}

format_tasks() {
	tasks=""
	# still needs work but it'll do for now
	tmp="${#task_hexs[@]}"
	if [ "$tmp" -gt "0" ]; then
		win_len="$[ $max_task_len / $tmp ]"
	else
		win_len="0"
	fi
	# make this better
	desk="$(xdotool get_desktop)" # put in an if
	for i in `seq 0 $[ $tmp - 1 ]`; do
		hex_i="${task_hexs[$i]}"
		win_i="${task_wins[$i]}"
		spacer=""
		name_len="$[ ${#win_i} + $format_len ]"
		if [ "$name_len" -lt "$win_len" ]; then
			spacer_len="$[ $win_len - $name_len ]"
			for i in `seq 0 $spacer_len`; do
				spacer+=" "
			done
		fi
		cut_len="$[ $win_len - $format_len - ${#spacer} ]"
		# get rid of multiple if-statements in future
		if [ "$active_win" = "$hex_i" ]; then
			if [ "$cdo" -eq "0" ]; then
				# can probably get rid of desk variable at some point
				# or add it back in or something
				tasks+=" ${win_i:0:1}"
				tasks+=") $active_col"
				tasks+="${win_i:1:$cut_len}$spacer$not_col"
			else
				tasks+=" $active_col"
				tasks+="${win_i:1:$cut_len}$spacer$not_col"
			fi
		else
			win_desk="${win_i:0:1}"
			if [ "$cdo" -eq "0" ]; then
				tasks+=" $win_desk) "
				tasks+="%{A:wmctrl -a $hex_i -i; xdotool windowactivate $hex_i:}"
				tasks+="${win_i:1:$cut_len}$spacer%{A}"
			else
				# obvs cdo=1 will still have click events later
				if [ "$win_desk" -eq "$desk" ]; then
					tasks+=" ${win_i:1:$cut_len}$spacer"
				fi
			fi
			# command on left click
		fi
	done
	echo "$tasks"
}

get_seconds_offset() {
	offset="$(date '+%S')"
	if [ "${offset:0:1}" = "0" ]; then
		offset="${offset:1}"
	fi
	offset="$[ $time_scale - $offset ]"
	offset="$[ $offset / $slp ]"
}

sync_time_update() {
	tmp="$(date '+%S')"
	if [ "${tmp:0:1}" = "0" ]; then
		tmp="${tmp:1}"
	fi
	if [ "$tmp" -gt "5" ]; then
		minute_scaled="$[ $time_scale - $tmp + 2 ]"
		minute_scaled="$[ $minute_scaled / $slp ]"
	elif [ "$tmp" -gt "2" ]; then
		minute_scaled="$[ $minute_scaled - 1 ]"
	else
		minute_scaled="$[ $time_scale / $slp ]"
	fi
}

update_bar() {
	if [ "$update_now" -eq "1" ]; then
#		bar_text="%{l} $desk$tasks""%{c}$cur""%{r}$per "
#		echo "$bar_text"
		echo "%{l} ${information[0]}%{c}${information[1]}%{r}${information[2]} "
		update_now="0"
	fi
}

# either just make coder remember the place in array that certain info
# is, or do a nfancurve thing with two arrays that use each other
update_information() {
	information["$1"]="$2"
}

try_update() {
	tmp="$1"
	old_tmp="$2"
	arr_pos="$3"
	if [ "$tmp" != "$old_tmp" ]; then
		update_information "$arr_pos" "$tmp"
		update_now="1"
	fi
}

init_values() {
	# second offsets isn't to be displayed on panel
	get_seconds_offset

	# these are and are in display order (not needed)
	information+=( "$(get_tasks)" )
	information+=( "$(get_date)" )
	information+=( "$(get_battery)" )
}

run_min_cmds() {
	try_update "$(get_tasks)" "${information[0]}" "0"
	# get_tasks already checks for change so don't use try_update
#	update_information "0" "$(get_tasks)"
	update_bar
	sleep "$slp"
}

main() {
	init_values

	for i in `seq 0 $offset`; do
		run_min_cmds
	done
	unset offset

	sync_time_update

	while true; do
		for i in `seq 0 4`; do
			update_information "1" "$(get_date)"
			for i in `seq 0 $minute_scaled`; do
				run_min_cmds
			done
		update_information "2" "$(get_battery)"
		sync_time_update
		update_now="1"
		done
	done
}

main
