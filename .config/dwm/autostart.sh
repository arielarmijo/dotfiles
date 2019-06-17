#!/bin/bash
feh --bg-scale /home/aarmijo/.wallpapers/space_01.png 
urxvtd -q -o -f
compton -b 
conky | while read LINE; do xsetroot -name "$LINE"; done &
nm-applet & 
volumeicon &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/evolution-data-server/evolution-alarm-notify
