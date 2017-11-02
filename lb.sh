#!/bin/bash

# Modify these if you like
slp="5"
time_scale="59"

# Don't change these
tmp=""
min="0"
offset="0"
new_per="0"
new_desk="0"
update_now="0"

options="$1"
minute_scaled="$[ $time_scale / $slp ]"
declare -a cmd_arr=()

function finish {
	unset per
	unset tmp
	unset time_scale
	unset new_per
	unset min
	unset options
	unset new_desk
	unset update_now
	unset cur
	unset offset
	unset wind
	unset desk
	unset slp
	unset minute_scaled
}
trap finish EXIT

function get_focused_window {
	tmp="$(xdotool getwindowfocus getwindowname)"
	if [ "$tmp" != "$wind" ]; then
		wind="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_battery {
    new_per="$(acpi --battery | cut -d, -f2)"
    if [ "$new_per" != "$per" ]; then
	    per="$new_per"
	    update_now="1"
	fi
}

function get_date {
	tmp="$(date '+%a %b %d, %H:%M')"
	if [ "$tmp" != "$cur" ]; then
		cur="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_desktop {
	new_desk="$(wmctrl -d | grep '*')"
	new_desk="${new_desk:0:1}"
#	new_desk="$(xdotool get_desktop)"
	if [ "$new_desk" != "$desk" ]; then
	    desk="$new_desk"
		update_now="1"
	fi
}

function get_offset {
	offset="$(date '+%S')"
	offset="$[ $time_scale - $offset ]"
	offset="$[ $offset / $slp ]"
}

function sync_time_update {
	tmp="$(date '+%S')"
	if [ "$tmp" -gt "5" ]; then
		minute_scaled="$[ $time_scale - $tmp + 2 ]"
		minute_scaled="$[ $minute_scaled / $slp ]"
	elif [ "$tmp" -gt "2" ]; then
		minute_scaled="$[ $minute_scaled - 1 ]"
	else
		minute_scaled="$[ $time_scale / $slp ]"
	fi
#	elif [ "$tmp" -ge "0" ] || [ "$tmp" -le "2" ]; then
	unset tmp
}

function init_values {
	get_offset
	get_date
	get_battery
	get_desktop
#	get_focused_window
}

function update_bar {
	if [ "$update_now" -eq "1" ]; then
		echo "%{l} [$desk]""%{c}$cur""%{r}$per "
		update_now="0"
	fi
}

function main {
	init_values

	for i in `seq 0 $offset`; do
#		get_focused_window
		get_desktop
		update_bar
		sleep "$slp"
	done
	unset offset

	sync_time_update

	while true; do
		get_date
		if [ "$min" -eq "5" ]; then
			get_battery
			sync_time_update
			min="0"
		fi
		for i in `seq 0 $minute_scaled`; do
#			get_focused_window
			get_desktop
			update_bar
			sleep "$slp"
		done
		min="$[ $min + 1 ]"
	done
}

main
