#!/bin/bash

slp_track=0
max_st=59

declare -a cmd_arr=()

function finish {
	unset per
	unset cur
	unset wind
	unset desk
	unset slp_track
	unset max_st
	unset cmd_arr
}
trap finish EXIT

function get_focused_window {
	wind=$(xdotool getwindowfocus getwindowname)
}

function get_battery {
	per=$(acpi --battery) #| cut -d, -f2)
	per=${per:11}
}

function get_date {
	cur=$(date "+%a %b %d, %H:%M:%S")
}

function get_desktop {
	desk=$(wmctrl -d | grep "*")
	desk=${desk:0:1}
}

function set_arr {
	for i in `seq 0 $max_st`; do
		if [ "$[ $i % 20 ]" -eq "0" ]; then
			cmd_arr+=( "get_battery;" )
		fi
		cmd_arr+=( "get_focused_window; get_desktop; get_date;" )
	done
}

set_arr

while true; do
	eval ${cmd_arr[$slp_track]}
	echo "%{l} [$desk] $wind""%{c}$cur""%{r}$per "

	slp_track=$[ $slp_track + 1 ]
	if [ "$slp_track" -eq "$max_st" ]; then
		slp_track=0
	fi
	sleep 1
done
