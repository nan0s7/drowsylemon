#!/bin/bash

# How long to sleep for
slp="1"

# Variable initialisation
update_now="1"
declare -a info=()

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

update_bar() {
	if [ "$update_now" -eq "1" ]; then
		echo "%{l} ${info[3]} ${info[0]}%{c}${info[1]}%{r}${info[2]} "
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
	# second offsets isn't to be displayed on panel	get_seconds_offset
	update_information

	info+=( "$(format_tasks_string)" )
	info+=( "$(get_date)" )
	info+=( "$(get_battery)" )
	info+=( "$(update_desktop)" )
}

run_sec_cmds() {
	# Checks if the information is stale before updating
	update_information
	try_update "$(format_tasks_string)" "${info[0]}" "0"
	try_update "$(update_desktop)" "${info[3]}" "3"
	update_bar
	sleep "$slp"
}

main() {
	# Import all needed variables and functions from plugins
	source plugins/get_info.sh
	source plugins/get_tasks.sh
	source plugins/get_desktop.sh
	source plugins/get_time.sh

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
