#!/bin/bash

slp_track="0"
slp="2"
max_st="60"
tmp=""
old_tmp=""
update_now="0"

declare -a cmd_arr=()

function finish {
	unset per
	unset tmp
	unset old_tmp
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
	tmp="$wind"
	wind=$(xdotool getwindowfocus getwindowname)
	if [ "$tmp" != "$wind" ] && [ "$update_now" -ne "1" ]; then
		update_now="1"
	fi
	unset tmp
}

function get_battery {
#    tmp="$per"
	per=$(acpi --battery) #| cut -d, -f2)
    old_tmp="$per"
    if [ "$old_tmp" != "$per" ] && [ "$update_now" -ne "1" ]; then
	    per=${per:11}
	    update_now="1"
	fi
}

function get_date {
	tmp="$cur"
	cur=$(date "+%a %b %d, %H:%M")
	if [ "$tmp" != "$cur" ] && [ "$update_now" -ne "1" ]; then
		update_now="1"
	fi
	unset tmp
}

function get_desktop {
#	tmp="$desk"
	desk=$(wmctrl -d | grep "*")
    old_tmp="$desk"
	if [ "$old_tmp" != "$desk" ] && [ "$update_now" -ne "1" ]; then
	    desk=${desk:0:1}
		update_now="1"
	fi
	unset tmp
}

function update_bar {
	echo "%{l} [$desk] $wind""%{c}$cur""%{r}$per "
}

function set_arr {
	for i in `seq 0 $max_st`; do
		if [ "$[ $i % 20 ]" -eq "0" ]; then
			cmd_arr+=( "get_battery;" )
		fi
		cmd_arr+=( "get_desktop; get_date;" )
		cmd_arr+=( "get_date;" )
		cmd_arr+=( "get_focused_window; get_desktop;" )
	done
}

function main {
#	set_arr

	get_battery
	cur=0

	while true; do
		eval ${cmd_arr[$slp_track]}
#		cur=$[ $cur + 1 ]
		get_date
		get_focused_window
		get_desktop
		slp_track=$[ $slp_track + $slp ]
		if [ "$slp_track" -eq "$max_st" ]; then
			get_battery
			slp_track=0
		fi
		if [ "$update_now" -eq "1" ]; then
			update_now="0"
			update_bar
		fi
		sleep "$slp"
	done
}

main
