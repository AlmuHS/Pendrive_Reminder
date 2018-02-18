#!/bin/bash

#Copy auxiliar scripts
mkdir /usr/bin/pendrive-reminder
cp *.sh /usr/bin/pendrive-reminder

#copy udev rules and recharge udev
cp 1?-usb*.rules /etc/udev/rules.d/
udevadm control --reload-rules

#Copy polkit rules
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
then
	#If polkit version is >= 0.106, copy rules file	
	cp 10-*shutdown.rules /usr/share/polkit-1/rules.d/
else
	#if polkit version is < 0.106 copy pkla file to a temporal directory
	cp 50-inhibit-shutdown.pkla /usr/bin/pendrive-reminder
fi
