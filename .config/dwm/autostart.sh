#!/bin/bash
feh --bg-scale /home/aarmijo/.wallpapers/space_01.png 
urxvtd -q -o -f
compton -b 
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

while true; do

	tail=0 #number of spaces after the status line (needed for keep text position)
	cpu_usage=$(cpu_usage)
	
	if [ $cpu_usage -ge $cpu_usage_max ]; then
		status="\x03$cpu_icon $cpu_usage%\x01 "
		tail=$(($tail+1))
	else
		status="$cpu_icon $cpu_usage% "
	fi
	
	cpu_load_1m="$(cat /proc/loadavg | awk '{print $1}')"
	cpu_load_5m="$(cat /proc/loadavg | awk '{print $2}')"
	cpu_load_15m="$(cat /proc/loadavg | awk '{print $3}')"
	
	if (($(echo "$cpu_load_1m > $cpu_load_max" |bc -l))) || (($(echo "$cpu_load_5m > $cpu_load_max" |bc -l))) || (($(echo "$cpu_load_15m > $cpu_load_max" |bc -l))); then
		status+="\x03$load_icon \x01"
		tail=$(($tail+1))
	else
		status+="$load_icon "
	fi
	
	if (( $(echo "$cpu_load_1m > $cpu_load_max" |bc -l) )); then
		status+="\x03$cpu_load_1m\x01 "
		tail=$(($tail+1))
	else
		status+="$cpu_load_1m "
	fi

	if (( $(echo "$cpu_load_5m > $cpu_load_max" |bc -l) )); then
		status+="\x03$cpu_load_5m\x01 "
		tail=$(($tail+1))
	else
		status+="$cpu_load_5m "
	fi

	if (( $(echo "$cpu_load_15m > $cpu_load_max" |bc -l) )); then
		status+="\x03$cpu_load_15m\x01 "
		tail=$(($tail+1))
	else
		status+="$cpu_load_15m "
	fi

	cpu_temp=$(cat /sys/class/hwmon/hwmon1/temp1_input | cut -b 1-2)

	if [ $cpu_temp -ge $cpu_temp_max ]; then
		status+="\x03$temp_icon $cpu_temp°C\x01 $sep "
		tail=$(($tail+1))
	else
		status+="$temp_icon $cpu_temp°C $sep "
	fi

	date=$(date +"$date_format")
	time=$(date +$time_format)

	status+="$cal_icon $date $clock_icon $time"

	for (( c=1; c<=$tail; c++ )); do  
		status+=" "
	done
	
	xsetroot -name "$(echo -e $status)"
	sleep $(($refresh_time-1)) #cpu_usage takes 1 second to run

done &
nm-applet & 
volumeicon &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/evolution-data-server/evolution-alarm-notify &
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
