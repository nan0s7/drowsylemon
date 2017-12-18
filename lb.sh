#!/bin/bash

# How long to sleep for
slp="1"
# How many seconds in a minute minus one
time_scale="59"

# Variable initialisation
offset="0"
update_now="1"
declare -a information=()
minute_scaled="$[ $time_scale / $slp ]"

finish() {
	unset per
	unset tmp
	unset time_scale
	unset update_now
	unset offset
	unset slp
	unset minute_scaled
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

#get_desktop() {
#	desk="$(wmctrl -d)"
#	desk="${desk%*  \* *}"
#	desk="${desk: -1}"
#}

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
	information+=( "$(./get_tasks.sh)" )
	information+=( "$(get_date)" )
	information+=( "$(get_battery)" )
}

run_sec_cmds() {
	# Checks if the information is stale before updating
	try_update "$(./get_tasks.sh)" "{information[0]}" "0"
	update_bar
	sleep "$slp"
}

main() {
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
			update_information "1" "$(get_date)"
			# Essentially forces an update
			update_now="1"
			for j in `seq 0 $minute_scaled`; do
				run_sec_cmds
			done
		done
		update_information "2" "$(get_battery)"
		sync_time_update
	done
}

main
