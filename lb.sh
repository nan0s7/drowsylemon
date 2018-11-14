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

update_battery() {
	# This command will change in the future
	prf "$(acpi --battery | cut -d, -f2)"
}

update_bar() {
	if [ "$update_now" -eq "1" ]; then
		prf "%{l} $desks $tasks%{c}$dates%{r}$batts "
		update_now="0"
	fi
}

init_values() {
	update_information
	tasks="$(format_tasks_string)"
	desks="$(update_desktop)"
#	batts="$(update_battery)"
	dates="$(get_date)"
}

run_sec_cmds() {
	update_information
	# Checks if the information is stale before updating
	tmp="$(format_tasks_string)"
	if [ "$tasks" != "$tmp" ]; then
		tasks="$tmp"
		update_now="1"
	fi
	tmp="$(update_desktop)"
	if [ "$desks" != "$tmp" ]; then
		desks="$tmp"
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
			dates="$(get_date)"
			update_now="1"
			for j in $(seq 0 $minute_scaled); do
				run_sec_cmds
			done
		done
#		batts="$(update_battery)"
		sync_time_update
	done
}

main
