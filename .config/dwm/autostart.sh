#!/bin/bash
feh --bg-scale /home/aarmijo/.wallpapers/space_01.png 
urxvtd -q -o -f
compton -b 
conky | while read LINE; do xsetroot -name "$LINE"; done &
nm-applet & 
volumeicon &
#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
