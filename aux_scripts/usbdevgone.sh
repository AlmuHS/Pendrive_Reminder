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

#if the USB's id is in the file, remove it
sed -in "\%${devpath}%d" $filepath

#After remove the id, check if file is empty
if ! test -s $filepath  
then
	#if file is empty, remove it
	rm $filepath

	#Notify all connected users
	user_list=$(who | cut -d " " -f 1)

	for user in $user_list
	do
		export DISPLAY=":0"
		su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock disabled. Now you can shutdown your computer"'
		service polkit restart
	done
fi

#if file don't exists and polkit version is < 0.106, remove pkla file to disable polkit rule
if ! test -e $filepath && test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106
then
	rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
fi
