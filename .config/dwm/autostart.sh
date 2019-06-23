#!/bin/bash
feh --bg-scale /home/aarmijo/.wallpapers/space_01.png 
urxvtd -q -o -f
compton -b 
volumeicon &
nm-applet & 
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/evolution-data-server/evolution-alarm-notify &
/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh &
export SSH_AUTH_SOCK

#conky | while read LINE; do xsetroot -name "$LINE"; done &

# Icons for indicators (otf-font-awesome)
cpu_icon="" 
load_icon=""
temp_icon=""
cal_icon=""
clock_icon=""
sep="〉"

# Thresholds
cpu_usage_max=95
cpu_load_max=2.00
cpu_temp_max=70
date_format="%a %d %b %Y"
time_format="%H:%M"
refresh_time=5

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
	temp=$(cat /sys/class/hwmon/hwmon1/temp1_input | cut -b 1-2)
	if [ $temp -ge $cpu_temp_max ]; then
		status+="\x03$temp_icon $temp°C\x01 $sep "
		tail=$(($tail+1))
	else
		status+="$temp_icon $temp°C $sep "
	fi
}

function date_time {
	date=$(date +"$date_format")
	time=$(date +"$time_format")
	status+="$cal_icon $date $clock_icon $time"
}

function add_tail {
	for (( c=1; c<=$tail; c++ )); do  
		status+=" "
	done
}

while true; do
	status=""
	tail=0
	cpu_usage
	cpu_load
	cpu_temp
	date_time
	add_tail
#	echo -e "$status"
	xsetroot -name "$(echo -e "$status")"
	sleep $refresh_time
done &
