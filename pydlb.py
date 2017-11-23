import subprocess, time

def print_bar_information(info):
	subprocess.call(["echo", "-e", info])

def set_left_information(info):
	left = " %{l}" + str(info)
	return left

def set_middle_information(info):
	middle = "%{c}" + str(info)
	return middle

def set_right_information(info):
	right = "%{r}" + str(info) + " "
	return right

def get_time_offset(time_scale, sleep):
	offset = subprocess.run(["date", "+%S"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	offset = -(-(time_scale - int(offset)) // sleep)
	offset = offset + 3
	return offset

def align_time(time_scale, sleep, minute_scaled):
	tmp = subprocess.run(["date", "+%S"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	tmp = int(tmp)
	if tmp > 14:
		new_ms = round((time_scale - tmp + 2) / sleep)
	elif tmp > 7:
		new_ms = minute_scaled - 1
	elif tmp > 2:
		new_ms = round(time_scale / sleep)
	else:
		new_ms = round(time_scale / sleep) + 1
	return new_ms

def get_date():
	tmp = subprocess.run(["date", "+%a %b %d, %H:%M"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	return tmp[:-1]

def get_battery():
	tmp = subprocess.run(["acpi", "--battery"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	per = tmp.find("%")
	comma = tmp.find(",")
	return tmp[comma + 2: per + 1]

def get_desktop():
	tmp = subprocess.run(["wmctrl", "-d"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	return tmp[tmp.find("*") - 3]

def get_tasks(name_len):
	tmp_array = []
	new_array = []
	tmp = subprocess.run(["wmctrl", "-l"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	while True:
		place = tmp.find("\n") + 1
		if place < 1:
			break
		else:
			tmp_array.append(tmp[:place - 1])
			tmp = tmp[place:]
	for i in range(len(tmp_array)):
		new_array.append(tmp_array[i][:10])
		new_array.append(int(tmp_array[i][12:13]))
		new_array.append(tmp_array[i][14 + name_len:])
	return new_array

def extract_winfo(array):
	tmp = []
	for i in range(len(array)):
		if not ((i == 0) or (i % 3 == 0)):
			tmp.append(array[i])
#	print(tmp)
	return tmp

def extract_wcodes(array):
	tmp = []
	for i in range(len(array)):
		if (i == 0) or (i % 3 == 0):
			tmp.append(array[i])
	return tmp

def formulate_string(array, max_len, codes):
	windows = []
	desktops = []
#	string = " %{B#696969} "
	string = " "
	col_active = "%{B#696969}"
	col_inactive = "%{B#313131}"
	win_active = subprocess.run(["xprop", "-root"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	find_string = "_NET_ACTIVE_WINDOW(WINDOW): window id # "
	tmp = win_active.find(find_string) + len(find_string)
	win_active = win_active[tmp:]
	tmp_end = win_active.find("\n")
	win_active = win_active[:tmp_end]
#	print(tmp)
#	print(tmp_end)
#	print(len(win_active))

	# FIX THIS::::
	if len(win_active) == 9:
		win_active = win_active[:2] + "0" + win_active[2:]
	elif len(win_active) == 8:
		win_active = win_active[:2] + "00" + win_active[2:]
#	print(win_active)


	for i in range(len(array)):
		if not isinstance(array[i], int):
			windows.append(array[i])
		else:
			desktops.append(array[i])
	space_len = round(max_len / len(windows))
	space_len -= 2
	for i in range(len(windows)):
#		print(codes[i])
		if codes[i] == win_active:
			string += col_active
		else:
			string += col_inactive
		string += "%{A:wmctrl -a " + codes[i] + " -i; " \
		 + "xdotool windowactivate " + codes[i] \
		 + ":} "
		if len(windows[i]) < space_len:
			string += windows[i]
		else:
			string += windows[i][:space_len]
		string += (" " * (space_len - len(windows[i]) - 2)) \
		 + " " + col_inactive + "|" + "%{A}"
	string += "%{B-}"
#	print(string)
	return string

'''
def format_desktop(string, selected):
	selected = int(selected)
	cb = "%{B#290303 F#ffffff}"
	cf = "%{B#470404 F#ffffff}"
	cm = "%{B#950b43 F#ffffff}"
	if selected == 0:
		new_info = cb
	else:
		new_info = cb + " " + string[:selected * 2 - 1]
	re = "%{B- F-}"
	new_info += \
	 cf + " " + cm +\
	 string[selected * 2] +\
	 cf + " " + cb +\
	 string[selected * 2 + 2:] + re
	return new_info
'''

def format_desktop(string):
	# add custom tags in config file
	new_info = " >" + str(string) + ": " + "tag"
	return new_info

def format_date(string):
	cm = "%{U#19d8a7 +u}"
	re = "%{U- -u}"
	new_info = \
	 cm + string + re
	return new_info

def set_bar_information(left, middle, right):
	info = \
	 set_left_information(left) +\
	 set_middle_information(middle) +\
	 set_right_information(right)
	return info

def main():
	sleep = 1
	time_scale = 59
	minute_scaled = 0
	bar_information = ""
	bar_battery = ""
	bar_date = ""
	bar_desktop = ""
	left_info = ""
	middle_info = ""
	right_info = ""
	minute = 0
	tasks_size = 103

	name_len = len(subprocess.run(["uname", "-n"], stdout=subprocess.PIPE).stdout.decode('utf-8'))
	bar_tasks = []
	tasks_info = []
#	while True:
	tasks_info = get_tasks(name_len)
#		bt_wo_hex = extract_winfo(tasks_info)
	bar_tasks = formulate_string(extract_winfo(tasks_info), tasks_size, extract_wcodes(tasks_info))
#		print_bar_information(bar_tasks)
#		time.sleep(1)

#	num_desktops = 9
#	exp_desktops = ""
#	for i in range(num_desktops):
#		exp_desktops += str(i) + " "

	offset = get_time_offset(time_scale, sleep)

	# init values
	bar_desktop = get_desktop()
	bar_date = get_date()
	bar_battery = get_battery()
#	left_info = format_desktop(exp_desktops, bar_desktop)
	left_info = format_desktop(bar_desktop) + bar_tasks
	middle_info = format_date(bar_date)
	right_info = bar_battery
	bar_information = set_bar_information(left_info, middle_info, right_info)
	print_bar_information(bar_information)

	# fix time
	for i in range(offset):
		tmp_desktop = bar_desktop
		bar_desktop = get_desktop()
		tmp_tasks = bar_tasks
		tasks_info = get_tasks(name_len)
		bar_tasks = formulate_string(extract_winfo(tasks_info), tasks_size, extract_wcodes(tasks_info))
		if (tmp_desktop != bar_desktop) or (tmp_tasks != bar_tasks):
#			left_info = format_desktop(exp_desktops, bar_desktop)
			left_info = format_desktop(bar_desktop) + bar_tasks
			bar_information = set_bar_information(left_info, middle_info, right_info)
			print_bar_information(bar_information)
		time.sleep(sleep)

	minute_scaled = align_time(time_scale, sleep, minute_scaled)

	while True:
#		minute_scaled = align_time(time_scale, sleep, minute_scaled)
		bar_date = get_date()
		middle_info = format_date(bar_date)
		if minute == 5:
			minute_scaled = align_time(time_scale, sleep, minute_scaled)
			bar_battery = get_battery()
			right_info = bar_battery
			minute = 0
		bar_information = set_bar_information(left_info, middle_info, right_info)
		print_bar_information(bar_information)
		for i in range(minute_scaled):
			tmp_desktop = bar_desktop
			bar_desktop = get_desktop()
			tmp_tasks = bar_tasks
			tasks_info = get_tasks(name_len)
			bar_tasks = formulate_string(extract_winfo(tasks_info), tasks_size, extract_wcodes(tasks_info))
#			if tmp != bar_desktop:
			if (tmp_desktop != bar_desktop) or (tmp_tasks != bar_tasks):
#				left_info = format_desktop(exp_desktops, bar_desktop)
				left_info = format_desktop(bar_desktop) + bar_tasks
				bar_information = set_bar_information(left_info, middle_info, right_info)
				print_bar_information(bar_information)
			time.sleep(sleep)
		minute += 1

main()

# TODO
# - make it more easily configurable / more general
# - make output prettier
