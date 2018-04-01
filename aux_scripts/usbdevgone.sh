#!/bin/bash

#Script linked to udev rule

#When usb device is disconnected, this script search the device's id in watchdog file
#If the device's id exists in the file, remove this id
#After remove device's id, if current file is empty, remove it 

#In polkit version < 0.106, this script also removes polkit pkla file to disable polkit rule
#The polkit pkla only will be removed when watchdog file don't exists in the system
#After disable this polkit rule, the shutdown will be unlocked

#USB Device identifier
devpath=$1 

#Path to USB watchdog file
filepath="/tmp/usbdevinfo"

#Get list of users with graphic session started, and their active display 
userdisplay=$(who | gawk '/\(:[[:digit:]](\.[[:digit:]])?\)/ { print $1 ";" substr($NF, 2, length($NF)-2) }' | uniq) 

polkit_version=$(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2)

#if watchdog file exists
if test -f $filepath
then
	#if the USB's id is in the file, remove it
	sed -in "\%${devpath}%d" $filepath

	#After remove the id, check if file is empty
	if ! test -s $filepath  
	then
		#if file is empty, remove it
		rm -f $filepath


		#if polkit version >= 106, kill all dbus clients
		if test $polkit_version -ge 106
		then
			
			while read pid
			do
				kill -9 $pid
			done < /tmp/pid_dbus

			#Remove temporary file
			rm /tmp/pid_dbus
		fi

		#Notify all connected users
		for element in $userdisplay
		do
			#get username		
			user=$(echo $element | cut -d ";" -f 1)

			#get display active of this user		
			export DISPLAY=$(echo $element | cut -d ";" -f 2)
			
			#Send notification to user
			su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock disabled. Now you can shutdown your computer"'
		done
	fi

fi




#if watchdog file don't exists and polkit version is < 0.106, remove pkla file to disable polkit rule
if ! test -f $filepath && test $polkit_version -lt 106
then
	rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla 2>/dev/null
	service polkit restart
fi
