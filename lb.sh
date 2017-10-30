#!/bin/bash

# Modify these if you like
slp="2"
time_scale="59"

# Don't change these
tmp=""
offset="0"
old_per="0"
old_desk="0"
update_now="0"

options="$1"
max_sleep="$minute_scaled"
minute_scaled="$[ $time_scale / $slp ]"

declare -a cmd_arr=()

function finish {
	unset per
	unset tmp
	unset time_scale
	unset max_sleep
	unset old_per
	unset old_desk
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
	tmp=$(xdotool getwindowfocus getwindowname)
	if [ "$tmp" != "$wind" ]; then
		wind="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_battery {
	tmp=$(acpi --battery)
    if [ "$old_per" != "$tmp" ]; then
	    old_per="$per"
	    per="$tmp"
	    #per=${per:11}
	    per=`echo $tmp | cut -d, -f2`
	    update_now="1"
	fi
	unset tmp
}

function get_date {
	tmp=$(date "+%a %b %d, %H:%M")
	if [ "$tmp" != "$cur" ]; then
		cur="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_desktop {
	tmp=$(wmctrl -d | grep "*")
	if [ "$old_desk" != "$tmp" ]; then
	    old_desk="$desk"
	    desk="$tmp"
	    desk=${desk:0:1}
		update_now="1"
	fi
	unset tmp
}

function get_offset {
	offset=$(date "+%S")
	offset="$[ $time_scale - $offset ]"
	offset="$[ $offset / $slp ]"
}

function maintain_time_sync {
	tmp=$(date "+%S")
	if [ "$tmp" -gt "2" ]; then
		minute_scaled="$[ $minute_scaled - 1 ]"
	elif [ "$tmp" -ge "0" ] || [ "$tmp" -le "2" ]; then
		minute_scaled="$max_sleep"
	fi
	unset tmp
}

function init_values {
	get_offset
	get_date
	get_battery
	get_desktop
	get_focused_window
}

function update_bar {
	if [ "$update_now" -eq "1" ]; then
		echo "%{l} [$desk] $wind""%{c}$cur""%{r}$per "
		update_now="0"
	fi
}

function main {
	init_values

	for i in `seq 0 $offset`; do
		get_focused_window
		get_desktop
		update_bar
		sleep "$slp"
	done

	while true; do
		get_date
		get_battery
		maintain_time_sync
		for i in `seq 0 $minute_scaled`; do
			get_focused_window
			get_desktop
			update_bar
			sleep "$slp"
		done
	done
}

main
