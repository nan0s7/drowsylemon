#!/bin/bash

slp_track="0"
slp="2"
max_st="$[ 59 / $slp ]"
max_sleep="$max_st"
tmp=""
old_per=""
old_desk="0"
update_now="0"

declare -a cmd_arr=()

function finish {
	unset per
	unset tmp
	unset old_per
	unset old_desk
	unset update_now
	unset cur
	unset wind
	unset desk
	unset slp_track
	unset slp
	unset max_st
	unset cmd_arr
}
trap finish EXIT

function get_focused_window {
	tmp=$(xdotool getwindowfocus getwindowname)
	if [ "$tmp" != "$wind" ]; then #&& [ "$update_now" -ne "1" ]; then
		wind="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_battery {
	tmp=$(acpi --battery) #| cut -d, -f2)
    if [ "$old_per" != "$tmp" ]; then #&& [ "$update_now" -ne "1" ]; then
	    old_per="$per"
	    per="$tmp"
	    per=${per:11}
	    update_now="1"
	fi
	unset tmp
}

function get_date {
	tmp=$(date "+%a %b %d, %H:%M")
	if [ "$tmp" != "$cur" ]; then #&& [ "$update_now" -ne "1" ]; then
		cur="$tmp"
		update_now="1"
	fi
	unset tmp
}

function get_desktop {
	tmp=$(wmctrl -d | grep "*")
	if [ "$old_desk" != "$tmp" ]; then #&& [ "$update_now" -ne "1" ]; then
	    old_desk="$desk"
	    desk="$tmp"
	    desk=${desk:0:1}
		update_now="1"
	fi
	unset tmp
}

function get_offset {
	offset=$(date "+%S")
	offset=$[ 59 - $offset ]
	offset=$[ $offset / $slp ]
}

function maintain_time_sync {
	tmp=$(date "+%S")
	if [ "$tmp" -gt "2" ]; then
		max_st="$[ $max_st - 1 ]"
	elif [ "$tmp" -ge "0" ] || [ "$tmp" -le "2" ]; then
		max_st="$max_sleep"
	fi
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

function set_arr {
	tmp="get_battery;"
	for i in `seq 0 $max_st`; do
		tmp="$tmp""get_date;get_desktop;get_focused_window;"
		cmd_arr+=( "$tmp" )
		tmp=""
	done
}

function main {
#	set_arr

#	get_battery
#	cur=0
	init_values
	update_bar

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
		for i in `seq 0 $max_st`; do
#			eval ${cmd_arr[$i]}
#			cur=$[ $cur + 1 ]
			get_focused_window
			get_desktop
#			if [ "$slp_track" -eq "$max_st" ]; then
#				get_battery
#				slp_track=0
#			fi
			update_bar
#			slp_track=$[ $slp_track + $slp ]
			sleep "$slp"
		done
	done
}

main
