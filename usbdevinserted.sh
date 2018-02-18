#!/bin/bash

set 2>&1 | grep DEVPATH | cut -d "=" -f 2 >> /tmp/usbdevinfo

if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106
then
	cp /tmp/50-inhibit-shutdown.pkla /etc/polkit-1/localauthority/50-local.d/
	service polkit restart
fi
