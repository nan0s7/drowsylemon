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
	if tmp > 14:
		return round((time_scale - tmp + 2) / sleep)
	elif tmp > 7:
		return minute_scaled - 1
	elif tmp > 2:
		return round(time_scale / sleep)
	else:
		return round(time_scale / sleep) + 1

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
	min = 0

	offset = get_time_offset(time_scale, sleep)

	# init values
	bar_desktop = get_desktop()
	bar_date = get_date()
	bar_battery = get_battery()
	left_info = bar_desktop
	middle_info = bar_date
	right_info = bar_battery
	bar_information = set_bar_information(left_info, middle_info, right_info)
	print_bar_information(bar_information)

	# fix time
	for i in range(offset):
		tmp = bar_desktop
		bar_desktop = get_desktop()
		if tmp != bar_desktop:
			left_info = bar_desktop
			bar_information = set_bar_information(left_info, middle_info, right_info)
			print_bar_information(bar_information)
		time.sleep(sleep)

	minute_scaled = align_time(time_scale, sleep, minute_scaled)

	while True:
		minute_scaled = align_time(time_scale, sleep, minute_scaled)
		bar_date = get_date()
		middle_info = bar_date
		if min == 5:
			bar_battery = get_battery()
			right_info = bar_battery
			min = 0
		bar_information = set_bar_information(left_info, middle_info, right_info)
		print_bar_information(bar_information)
		for i in range(minute_scaled):
			tmp = bar_desktop
			bar_desktop = get_desktop()
			if tmp != bar_desktop:
				left_info = bar_desktop
				bar_information = set_bar_information(left_info, middle_info, right_info)
				print_bar_information(bar_information)
			time.sleep(sleep)
		min += 1

main()
