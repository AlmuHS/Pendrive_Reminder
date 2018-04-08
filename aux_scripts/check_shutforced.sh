#!/bin/bash

#Path to USB identifiers list file
filepath="/tmp/usbdevinfo"
pklapath="/etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla"


#if file don't exists
if ! test -e $filepath
then
	#if polkit version is < 0.106, remove pkla file to disable polkit rule
	if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106 && test -e $pklapath
	then
		rm $pklapath
		service polkit restart
	fi

       #check linux distribution and version
	distro=$(grep '^ID=' /etc/os-release | cut -d = -f 2)
	version=$(grep "VERSION_ID" /etc/os-release | cut -d "=" -f 2)

	if test $distro = "ubuntu" && test $version = "\"17.10\""
	then
		#Restart udev
		systemctl restart udev
	fi

	

fi



