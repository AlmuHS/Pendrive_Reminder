#!/bin/bash

#Copy auxiliar scripts
mkdir /usr/bin/pendrive-reminder 2>/dev/null
cp aux_scripts/* /usr/bin/pendrive-reminder
chmod +x /usr/bin/pendrive-reminder/*.sh

#copy udev rules and recharge udev
cp udev-rules/* /etc/udev/rules.d/
udevadm control --reload-rules

#Copy polkit rules
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
then
	#If polkit version is >= 0.106, copy rules file	
	cp polkit-rules/10-inhibit-shutdown.rules /usr/share/polkit-1/rules.d/
else
	#if polkit version is < 0.106 copy pkla file to a temporal directory
	cp polkit-rules/50-inhibit-shutdown.pkla /usr/bin/pendrive-reminder
fi
