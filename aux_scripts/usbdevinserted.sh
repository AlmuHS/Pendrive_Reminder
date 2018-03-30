#!/bin/bash

#Script linked to udev rule

#Generates a watchdog file, adding the id of usb storage device when it is connected
#The watchdog file will be in /tmp/usbdevinfo

#In polkit version < 0.106, this script also copy polkit pkla file to add polkit rule
#This polkit rule locks the shutdown while usb storage devices are connected to the machine


#Copy USB identifier in usbdevinfo watchdog file.
#This file will be used to detect if there are any usb storage device connected to the machine
set 2>&1 | grep DEVPATH | cut -d "=" -f 2 >> /tmp/usbdevinfo

#Path to installation directory
INSTALL_DIR="/usr/bin/pendrive-reminder"

#Get list of users with graphic session started, and their active display 
userdisplay=$(who | gawk '/\(:[[:digit:]](\.[[:digit:]])?\)/ { print $1 ";" substr($NF, 2, length($NF)-2) }' | uniq) 

#Get polkit version
polkit_version=$(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2)

#In polkit version < 0.106, the rules file don't run, so we need to copy authority files
if test $polkit_version -lt 106
then

	#Check is pkla file exists in localauthority directory	
	if ! test -f /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
	then
		#If it don't exists, copy pkla file in localauthority directory		
		cp $INSTALL_DIR/50-inhibit-shutdown.pkla /etc/polkit-1/localauthority/50-local.d/
		service polkit restart
	fi
fi

#When first usb device is connected
if test $(wc -l /tmp/usbdevinfo | cut -d " " -f 1) -eq 1
then	
	#for each user, show notification and (only in polkit >= 106) launch dbus client 
	for element in $userdisplay
	do			
		#get username		
		user=$(echo $element | cut -d ";" -f 1)
		
		#get display active of this user		
		export DISPLAY=$(echo $element | cut -d ";" -f 2)
		
		#Send notification to user
		su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock enabled. The shutdown will be unlocked when pendrive is disconnected"'
		#if polkit version >=106, also launch dbus client
		if test $polkit_version -ge 106
		then
			su $user -c 'python /usr/bin/pendrive-reminder/client.py' &
		fi
	done
fi

exit 0

