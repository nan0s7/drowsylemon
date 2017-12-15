#!/bin/bash

slp="1"
time_scale="59"
offset="0"
update_now="1"
old_bar_text=""
bar_text=""

minute_scaled="$[ $time_scale / $slp ]"

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

# make this better so I don't have to use xdotool
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

run_min_cmds() {
	try_update "$(./get_tasks.sh)" "{information[0]}" "0"
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
			update_now="1"
			for i in `seq 0 $minute_scaled`; do
				run_min_cmds
			done
		done
		update_information "2" "$(get_battery)"
		sync_time_update
	done
}

main
