#!/bin/bash

############################# Autostart Programs ###################################

wallpaper="$(cat ~/.fehbg | grep feh | awk '{print $4}' | sed 's/\x27//g')"

feh --bg-scale $wallpaper
urxvtd -q -o -f
compton -b
volumeicon &
nm-applet & 
xautolock -time 30 -locker "i3lock -nti $wallpaper" &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/evolution-data-server/evolution-alarm-notify &
/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
export SSH_AUTH_SOCK


############################# Variables ############################################

# Icons for indicators (DejaVuSans Nerd Fonts)
boot_icon=""
root_icon=""
home_icon=""
cpu_icon="﬙"
load_icon=""
temp_icon=""
cal_icon=""
clock_icon=""
sep="〉"

# Thresholds
disk_usage_max=90
cpu_usage_max=95
cpu_load_max=2.00
cpu_temp_max=70
date_format="%a %d %b %Y"
time_format="%H:%M"
refresh_time=5


############################# Functions ############################################

function disk_usage {
	case $1 in
		/ )
			icon=$root_icon
			usage="$(df -h | awk '{ if ($6 == "/") print $5 }')"
			;;
		/boot )
			icon=$boot_icon
			usage="$(df -h | awk '{ if ($6 == "/boot") print $5 }')"
			;;
		/home )
			icon=$home_icon
			usage="$(df -h | awk '{ if ($6 == "/home") print $5 }')"
			;;
	esac

	if [ ${usage%?} -ge $disk_usage_max ]; then
		status+="\x03$icon $usage\x01 "
		tail=$(($tail+1))
	else
		status+="$icon $usage "
	fi
}

status=""
tail=0
new=(0 0 0 0 0 0 0 0 0 0)

function cpu_usage {
	prev=("${new[@]}")
	new=($(sed -n 's/^cpu\s\s//p' /proc/stat))
#	echo "      user nice system idle iowait  irq  softirq steal guest guest_nice"
#	echo "prev: ${prev[@]}"
#	echo "new:  ${new[@]}"
	total_time=$(( (${new[0]} + ${new[1]} + ${new[2]} +${new[3]} + ${new[4]} + ${new[5]} + ${new[6]} + ${new[7]}) \
	- \
	(${prev[0]} + ${prev[1]} + ${prev[2]} +${prev[3]} + ${prev[4]} + ${prev[5]} + ${prev[6]} + ${prev[7]}) ))
	total_idle=$(( (${new[3]}+${new[4]}) - (${prev[3]}+${prev[4]}) ))
	total_usage=$(($total_time - $total_idle))
	usage=$(($total_usage*100/$total_time))
#	echo "$usage%"
	
	if [ $usage -ge $cpu_usage_max ]; then
		status+="\x03$cpu_icon $usage%\x01 "
		tail=$(($tail+1))
	else
		status+="$cpu_icon $usage% "
	fi	
}

function cpu_load {
	load_1m="$(cat /proc/loadavg | awk '{print $1}')"
	load_5m="$(cat /proc/loadavg | awk '{print $2}')"
	load_15m="$(cat /proc/loadavg | awk '{print $3}')"
	
	if (($(echo "$load_1m > $cpu_load_max" |bc -l))) || \
	   (($(echo "$load_5m > $cpu_load_max" |bc -l))) || \
	   (($(echo "$load_15m > $cpu_load_max" |bc -l))); then
		status+="\x03$load_icon \x01"
		tail=$(($tail+1))
	else
		status+="$load_icon "
	fi
	
	if (( $(echo "$load_1m > $cpu_load_max" |bc -l) )); then
		status+="\x03$load_1m\x01 "
		tail=$(($tail+1))
	else
		status+="$load_1m "
	fi

	if (( $(echo "$load_5m > $cpu_load_max" |bc -l) )); then
		status+="\x03$load_5m\x01 "
		tail=$(($tail+1))
	else
		status+="$load_5m "
	fi

	if (( $(echo "$load_15m > $cpu_load_max" |bc -l) )); then
		status+="\x03$load_15m\x01 "
		tail=$(($tail+1))
	else
		status+="$load_15m "
	fi
}

function cpu_temp {
	temp=$(cat /sys/class/hwmon/hwmon2/temp1_input | cut -b 1-2)
	
	if [ $temp -ge $cpu_temp_max ]; then
		status+="\x03$temp_icon $temp°C\x01 "
		tail=$(($tail+1))
	else
		status+="$temp_icon $temp°C "
	fi
}

function date_time {
	date=$(date +"$date_format")
	time=$(date +"$time_format")
	status+="$cal_icon $date $clock_icon $time "
}

function add_tail {
	for (( c=1; c<=$tail; c++ )); do  
		status+=" "
	done
}	


############################ Main #####################################################

while true; do
	status=""
	tail=0
	disk_usage /boot
	disk_usage /
	disk_usage /home
	status+="$sep"
	cpu_usage
	cpu_load
	cpu_temp
	status+="$sep"
	date_time
	add_tail
#	echo -e "$status"
	xsetroot -name "$(echo -e "$status")"
	sleep $refresh_time
done &
