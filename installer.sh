#!/bin/bash

#Copy auxiliar scripts
cp *.sh /usr/bin

#copy udev rules and recharge udev
cp 1?-usb*.rules /etc/udev/rules.d/
udevadm control --reload-rules

#Copy polkit rules
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
then
	cp 10-*shutdown.rules /usr/share/polkit-1/rules.d/
fi
