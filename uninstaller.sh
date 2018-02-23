#!/bin/bash

#Remove scripts folder
rm -r /usr/bin/pendrive-reminder

#Remove udev rules
udev_files=$(ls udev-rules)

cd /etc/udev/rules.d/
rm $udev_files

#If polkit version is >= 0.106, remove rules file	
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
then
	rm /usr/share/polkit-1/rules.d/10-inhibit-shutdown.rules

#if polkit < 0.106, remove pkla file
else
	rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
fi

