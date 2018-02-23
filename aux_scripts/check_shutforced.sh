#!/bin/bash

#Path to USB identifiers list file
filepath="/tmp/usbdevinfo"

#if file don't exists
if ! test -e $filepath
then
	#if polkit version is < 0.106, remove pkla file to disable polkit rule
	if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106
	then
		rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
		service polkit restart
	fi
fi
