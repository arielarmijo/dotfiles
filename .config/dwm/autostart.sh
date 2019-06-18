#!/bin/bash
#feh --bg-scale /home/aarmijo/.wallpapers/space_01.png 
#urxvtd -q -o -f
#compton -b 
#conky | while read LINE; do xsetroot -name "$LINE"; done &

# Font: otf-font-awesome
cpu_icon=""
load_icon=""
temp_icon=""
cal_icon=""
clock_icon=""
sep="〉"

while true; do
	status=""
	cpu_usage="$(cpu_usage)"
	
	if [ $cpu_usage -ge 95 ]; then
		status+="\x03$cpu_icon $cpu_usage%\x01 "
	else
		status+="$cpu_icon $cpu_usage% "
	fi
	
	cpu_load_1m="$(cat /proc/loadavg | awk '{print $1}')"
	cpu_load_5m="$(cat /proc/loadavg | awk '{print $2}')"
	cpu_load_15m="$(cat /proc/loadavg | awk '{print $3}')"
	
	if (($(echo "$cpu_load_1m > 2.00" |bc -l))) || (($(echo "$cpu_load_5m > 2.00" |bc -l))) ||  (($(echo "$cpu_load_15m > 2.00" |bc -l))); then
		status+="\x03$load_icon \x01"
	else
		status+="$load_icon "
	fi
	
	if (( $(echo "$cpu_load_1m > 2.00" |bc -l) )); then
		status+="\x03$cpu_load_1m\x01 "
	else
		status+="$cpu_load_1m "
	fi

	if (( $(echo "$cpu_load_5m > 2.00" |bc -l) )); then
		status+="\x03$cpu_load_5m\x01 "
	else
		status+="$cpu_load_5m "
	fi

	if (( $(echo "$cpu_load_15m > 2.00" |bc -l) )); then
		status+="\x03$cpu_load_15m\x01 "
	else
		status+="$cpu_load_15m "
	fi

	cpu_temp=$(cat /sys/class/hwmon/hwmon1/temp1_input | cut -b 1-2)

	if [ $cpu_temp -ge 70 ]; then
		status+="\x03$temp_icon $cpu_temp°C\x01 $sep"
	else
		status+="$temp_icon $cpu_temp°C $sep "
	fi

	date=$(date +"%a %d %b %Y")
	time=$(date +"%H:%M")
	status+="$cal_icon $date $clock_icon $time"
	xsetroot -name "$(echo -e $status)"
	sleep 4
done &

#nm-applet & 
#volumeicon &
#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
#/usr/lib/evolution-data-server/evolution-alarm-notify &
