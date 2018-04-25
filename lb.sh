#!/bin/bash

# How long one unit of sleep should be
slp="1"

# Import all needed variables and functions from plugins
source plugins/get_info.sh
source plugins/get_time.sh
source plugins/get_tasks.sh
source plugins/get_desktop.sh

# Variable initialisation
update_now="1"
declare -a info=()

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

force_update() {
	info["$1"]="$2"
}

try_update() {
	tmp="$1"
	arr_pos="$2"
	old_tmp="$3"
	if [ "$tmp" != "$old_tmp" ]; then
		force_update "$arr_pos" "$tmp"
		update_now="1"
	fi
}

init_values() {
	update_information

	info+=( "$(format_tasks_string)" )
	info+=( "$(get_date)" )
	info+=( "$(get_battery)" )
	info+=( "$(update_desktop)" )
}

run_sec_cmds() {
	update_information
	# Checks if the information is stale before updating
	try_update "$(format_tasks_string)" "0" "${info[0]}"
	try_update "$(update_desktop)" "3" "${info[3]}"
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
			force_update "1" "$(get_date)"
			# Essentially forces an update
			update_now="1"
			for j in `seq 0 $minute_scaled`; do
				run_sec_cmds
			done
		done
		force_update "2" "$(get_battery)"
		sync_time_update
	done
}

main
