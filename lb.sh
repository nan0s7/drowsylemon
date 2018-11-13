#!/bin/bash

prf() { printf %s\\n "$*" ; }

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
u=""

update_battery() {
	# This command will change in the future
    battery="$(acpi --battery | cut -d, -f2)"
}

update_bar() {
	if [ "$update_now" -eq "1" ]; then
#		prf "%{l} ${info[3]} ${info[0]}%{c}${info[1]}%{r}${info[2]} "
		prf "%{l} $desks $tasks%{c}$dates%{r}$batts "
		update_now="0"
	fi
}

try_update() {
	old="$1"
#	arr_pos="$2"
#	if [ "$tmp" != "${info[$arr_pos]}" ]; then
	if [ "$old" != "$u" ]; then
#		info["$arr_pos"]="$tmp"
		update_now="1"
	fi
}

init_values() {
	update_information
	format_tasks_string
	tasks="$tasks_string"
	update_desktop
	desks="$desktop_string"
	update_battery
	batts="$battery"
	get_date
	dates="$date_cmd"

#	info+=( "$tasks_string" )
#	info+=( "$(get_date)" )
#	info+=( "$battery" )
#	info+=( "$desktop_string" )
}

run_sec_cmds() {
	update_information
	# Checks if the information is stale before updating
	format_tasks_string
#	try_update "$tasks_string" 0
#	try_update "$(update_desktop)" "3" "${info[3]}"
	if [ "tasks" != "$tasks_string" ]; then
		tasks="$tasks_string"
		update_now="1"
	fi
	update_desktop
#	try_update "$desktop_string" 3
	if [ "desks" != "$desktop_string" ]; then
		desks="$desktop_string"
		update_now="1"
	fi
	update_bar
	sleep "$slp"
}

main() {
	init_values

	# Align when script checks for the current time to be accurate
	for i in $(seq 0 $offset); do
		# Means run commands that should execute/update every second
		run_sec_cmds
	done
	unset offset

	# Adjusts for computation time
	sync_time_update

	while true; do
		for i in $(seq 0 4); do
			# Doesn't bother checking if the command gave a new value
#			info[1]="$(get_date)"
			get_date
			dates="$date_cmd"
			# Essentially forces an update
			update_now="1"
			for j in $(seq 0 $minute_scaled); do
				run_sec_cmds
			done
		done
		update_battery
#		info[2]="$battery"
		batts="$battery"
		sync_time_update
	done
}

main
