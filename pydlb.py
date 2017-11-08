import subprocess, time

def print_bar_information(info):
	subprocess.call(["echo", info])
#	print(info)

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
	offset = round((time_scale - int(offset)) / sleep)
#	print("offset: " + str(offset))
	return offset

def align_time(time_scale, sleep, minute_scaled):
	tmp = subprocess.run(["date", "+%S"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	tmp = int(tmp)
	if tmp > 5:
		return (time_scale - tmp + 2) / sleep
	elif tmp > 2:
		return minute_scaled - 1
	else:
		return time_scale / sleep

def get_date():
	tmp = subprocess.run(["date", "+%a %b %d, %H:%M"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	return tmp[:-1]

def get_battery():
	tmp = subprocess.run(["acpi", "--battery"], stdout=subprocess.PIPE).stdout.decode('utf-8')
	per = tmp.find("%")
	comma = tmp.find(",")
	return tmp[comma + 2: per + 1]


def main():
	sleep = 1
	time_scale = 59
	minute_scaled = 0
	bar_information = ""

	offset = get_time_offset(time_scale, sleep)
	minute_scaled = align_time(time_scale, sleep, minute_scaled)

	for i in range(offset):
		bar_information = \
			set_middle_information(get_date()) +\
			set_right_information(get_battery())
		print_bar_information(bar_information)
		time.sleep(1)

	align_time(time_scale, sleep, minute_scaled)

#	ctime = get_date()

#	print("battery: " + str(get_battery()))
#	print("date: " + str(get_date()))

	while True:
		align_time(time_scale, sleep, minute_scaled)
		bar_information = \
			set_middle_information(get_date()) +\
			set_right_information(get_battery())
		print_bar_information(bar_information)
		time.sleep(1)

main()
