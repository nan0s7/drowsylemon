#!/bin/bash

# How long to sleep for
slp="1"
# How many seconds in a minute minus one
time_scale="59"

# Variable initialisation
offset="0"
update_now="1"
declare -a info=()
minute_scaled="$[ $time_scale / $slp ]"

finish() {
	unset per
	unset tmp
	unset time_scale
	unset update_now
	unset offset
	unset slp
	unset minute_scaled
	unset info
}
trap finish EXIT

get_battery() {
	# This command will change in the future
    echo "$(acpi --battery | cut -d, -f2)"
}

get_date() {
	echo "$(date '+%a %b %d, %H:%M')"
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
		echo "%{l} ${info[3]}${info[0]}%{c}${info[1]}%{r}${info[2]} "
		update_now="0"
	fi
}

# either just make coder remember the place in array that certain info
# is, or do a nfancurve thing with two arrays that use each other
update_info() {
	info["$1"]="$2"
}

try_update() {
	tmp="$1"
	old_tmp="$2"
	arr_pos="$3"
	if [ "$tmp" != "$old_tmp" ]; then
		update_info "$arr_pos" "$tmp"
		update_now="1"
	fi
}

init_values() {
	IFS=$'\n'

	# second offsets isn't to be displayed on panel
	get_seconds_offset
	update_information

	info+=( "$(format_tasks_string)" )
	info+=( "$(get_date)" )
	info+=( "$(get_battery)" )
	info+=( "$(update_desktop)" )
}

run_sec_cmds() {
	# Checks if the information is stale before updating
#	try_update "$(./get_tasks.sh)" "{info[0]}" "0"
	update_information
	try_update "$(format_tasks_string)" "${info[0]}" "0"
	try_update "$(update_desktop)" "${info[3]}" "3"
	update_bar
	sleep "$slp"
}

max_length="100"
icon_empty="o"
icon_used="x"
format_len="0"
fcol="ffffff"
bcol="000000"
desk_range="8"
#task_len="100"
update_tasks="0"
old_active_win=""
declare -a count=( "0" "0" "0" "0" "0" "0" "0" "0" "0" )
active_win=""
win_list=""
declare -a task_hexs=()
declare -a task_wins=()
declare -a task_desk=()
cdesk=""

main() {
	source get_info.sh
	source get_tasks.sh
	source get_desktop.sh

	init_values

	# Align when script checks for the current time to be accurate
	for i in `seq 0 $offset`; do
		# Means run commands that should execute/update every second
		run_sec_cmds
	done
	unset offset

	# Adjusts for computation time
	sync_time_update

	while true; do
		for i in `seq 0 4`; do
			# Doesn't bother checking if the command gave a new value
			update_info "1" "$(get_date)"
			# Essentially forces an update
			update_now="1"
			for j in `seq 0 $minute_scaled`; do
				run_sec_cmds
			done
		done
		update_info "2" "$(get_battery)"
		sync_time_update
	done
}

main
