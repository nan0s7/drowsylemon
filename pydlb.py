import subprocess, time

def print_bar_information(info):
	subprocess.call(["echo", info])

def set_left_information(info):
	left = "%{l}" + str(info)
	return left

def set_middle_information(info):
	middle = "%{c}" + str(info)
	return middle

def set_right_information(info):
	right = "%{r}" + str(info)
	return right

def get_time_offset(time_scale, sleep):
	offset = subprocess.run(["date", "+%S"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	offset = -(-(time_scale - int(offset)) // sleep)
	offset = offset + 3
	return offset

def align_time(time_scale, sleep, minute_scaled):
	tmp = subprocess.run(["date", "+%S"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	tmp = int(tmp)
	if tmp > 5:
		return round((time_scale - tmp + 2) / sleep)
	elif tmp > 2:
		return minute_scaled - 1
	else:
		return round(time_scale / sleep)

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

def set_bar_information(left, middle, right):
	info = \
		set_left_information(left) +\
		set_middle_information(middle) +\
		set_right_information(right)
	return info

def check_updatable(new_info, old_info):
	tmp = False
#	for i in range(len(new_info)):
	if new_info != old_info:
		tmp = True
	if tmp == True:
#		set_bar_information(left_info, middle_info, right_info)
#		bar_information = \
#			set_left_information(new_info[2]) +\
#			set_middle_information(new_info[0]) +\
#			set_right_information(new_info[1])
		print_bar_information(new_info)
	return tmp

def main():
	sleep = 1
	time_scale = 59
	minute_scaled = 0
	bar_information = ""
	old_information = ""
	bar_battery = ""
	bar_date = ""
	bar_desktop = ""
#	information_array = []
	left_info = ""
	middle_info = ""
	right_info = ""

	offset = get_time_offset(time_scale, sleep)
#	minute_scaled = align_time(time_scale, sleep, minute_scaled)

	# init values
#	information_array.append(get_date())
#	information_array.append(get_battery())
#	information_array.append(get_desktop())
	left_info = get_desktop()
	middle_info = get_date()
	right_info = get_battery()
	bar_information = set_bar_information(left_info, middle_info, right_info)
#	bar_information = \
#		set_left_information(left_info) +\
#		set_middle_information(middle_info) +\
#		set_right_information(right_info)
	# expand old_information
#	for i in range(len(information_array)):
#		old_information.append("")

	# fix time
	for i in range(offset):
#		bar_desktop = get_desktop()
#		information_array[2] = bar_desktop
		left_info = get_desktop()
#		print(bar_information)
		bar_information = set_bar_information(left_info, middle_info, right_info)
#		print(bar_information)
		tmp = check_updatable(bar_information, old_information)
		if tmp == True:
			old_information = bar_information
#			print("updated in offset")
		time.sleep(sleep)

#	minute_scaled = align_time(time_scale, sleep, minute_scaled)

	# force an update
#	information_array = []
#	information_array.append(get_date())
#	information_array.append(get_battery())
#	information_array.append(get_desktop())

#	left_info = get_desktop()
#	middle_info = get_date()
#	right_info = get_battery()
#	set_bar_information(left_info, middle_info, right_info)
#	tmp = check_updatable(bar_information, old_information)
#	if tmp:
#		old_information = bar_information

	while True:
		minute_scaled = align_time(time_scale, sleep, minute_scaled)

		middle_info = get_date()
		right_info = get_battery()
#		information_array = []
#		information_array.append(get_date())
#		information_array.append(get_battery())
		for i in range(minute_scaled):
#			bar_desktop = get_desktop()
#			if len(information_array) == 2:
#				information_array.append(bar_desktop)
#			else:
#				information_array[2] = bar_desktop
			left_info = get_desktop()
			bar_information = set_bar_information(left_info, middle_info, right_info)
			tmp = check_updatable(bar_information, old_information)
			if tmp == True:
				old_information = bar_information
#				print("updated in main")
			time.sleep(sleep)

main()

# need to seperate updates of individual information
