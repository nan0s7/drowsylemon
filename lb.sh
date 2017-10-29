#!/bin/bash

slp_track=0
max_st=60
tmp=""
update_now=0

declare -a cmd_arr=()

function finish {
	unset per
	unset tmp
	unset cur
	unset wind
	unset desk
	unset slp_track
	unset max_st
	unset cmd_arr
}
trap finish EXIT

function get_focused_window {
	tmp="$wind"
	wind=$(xdotool getwindowfocus getwindowname)
	if [ "$tmp" != "$wind" ] && [ "$update_now" -ne "1" ]; then
		update_now="1"
#		echo "updated window"
	fi
	unset tmp
}

function get_battery {
	per=$(acpi --battery) #| cut -d, -f2)
	per=${per:11}
}

function get_date {
	tmp="$cur"
	cur=$(date "+%a %b %d, %H:%M")
	if [ "$tmp" != "$cur" ] && [ "$update_now" -ne "1" ]; then
		update_now="1"
#		echo "updated date"
	fi
	unset tmp
}

function get_desktop {
	tmp="$desk"
	desk=$(wmctrl -d | grep "*")
	desk=${desk:0:1}
	if [ "$tmp" != "$desk" ] && [ "$update_now" -ne "1" ]; then
		update_now="1"
#		echo "updated desktop"
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
	#set_arr

	get_battery
	cur=0

	while true; do
		eval ${cmd_arr[$slp_track]}
		#if [ "$[ $slp_track % 20 ]" -eq "0" ]; then
		#	get_battery
		#fi
		get_date
#		cur=$[ $cur + 1 ]
		get_focused_window
		get_desktop
#		get_battery
		slp_track=$[ $slp_track + 1 ]
#		echo "slp_track="$slp_track
		if [ "$slp_track" -eq "$max_st" ]; then
			get_battery
#			echo "reset slp_track"
			slp_track=0
		fi
		if [ "$update_now" -eq "1" ]; then
			update_now="0"
#			echo "update_now="$update_now
#			echo "updated bar"
			update_bar
		fi
#		echo
		sleep 1
	done
}

function meh {
	while true; do
		sleep 1
	done
}

main
#meh
