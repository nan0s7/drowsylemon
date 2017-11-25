#!/bin/bash

# Modify these if you like
slp="1"
time_scale="59"

# Don't change these
tmp=""
min="0"
offset="0"
new_per="0"
new_desk="0"
update_now="0"

old_bar_text=""
bar_text=""

options="$1"
minute_scaled="$[ $time_scale / $slp ]"
declare -a cmd_arr=()

finish() {
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

get_focused_window() {
	tmp="$(xprop -root _NET_ACTIVE_WINDOW)"
	tmp="$(xprop -id ${tmp#*# *} _NET_WM_NAME)"
	tmp="${tmp#*= *}"
	tmp="${tmp//\"}"
	#tmp="$(xdotool getwindowfocus getwindowname)"
#	if [ "$tmp" != "$wind" ]; then
#		wind="$tmp"
#		update_now="1"
#	fi
	wind="$tmp"
#	unset tmp
}

get_battery() {
    per="$(acpi --battery | cut -d, -f2)"
#    echo "$per"
#   if [ "$tmp" != "$per" ]; then
#		per="$tmp"
#	    update_now="1"
#	fi
#	per="$tmp"
}

get_date() {
	cur="$(date '+%a %b %d, %H:%M')"
#	echo "$cur"
#	if [ "$tmp" != "$cur" ]; then
#		cur="$tmp"
#		if 
#	fi
}

get_desktop() {
	tmp="$(wmctrl -d)"
	tmp="${tmp%*  \* *}"
	desk="${tmp: -1}"
#	update_now="1"
#	desk="$tmp"
#	if [ "$tmp" != "$desk" ]; then
#		desk="$tmp"
#		echo "$desk"
#	fi
}

get_seconds_offset() {
	offset="$(date '+%S')"
	offset="$[ $time_scale - $offset ]"
	offset="$[ $offset / $slp ]"
}

sync_time_update() {
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
#	unset tmp
}

update_bar() {
#	tmp="$bar_text"
	bar_text="%{l} $desk""%{c}$cur""%{r}$per "
#	if ! [ "$bar_text" = "$tmp" ]; then
	echo "$bar_text"
#	fi
#	if [ "$update_now" -eq "1" ]; then
#		echo "%{l} $desk""%{c}$cur""%{r}$per "
#	fi
}

init_values() {
	get_seconds_offset
	get_date
	get_battery
	get_desktop
	get_focused_window
}

main() {
	init_values

	for i in `seq 0 $offset`; do
		get_focused_window
		get_desktop
#		check_new_vals
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
#			check_new_vals
			update_bar
			sleep "$slp"
		done
		min="$[ $min + 1 ]"
	done
}

main
