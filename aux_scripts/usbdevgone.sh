#!/bin/bash

#USB Device identifier
devpath=$1 

#Path to USB identifiers list file
filepath="/tmp/usbdevinfo"

#if the USB's id is in the file, remove it
sed -in "\%${devpath}%d" $filepath

#After remove the id, check if file is empty
if ! test -s $filepath  
then
	#if file is empty, remove it
	rm $filepath

	#if polkit version is < 0.106, remove pkla file to disable polkit rule
	if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106
	then
		rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
		service polkit restart
	fi
fi

