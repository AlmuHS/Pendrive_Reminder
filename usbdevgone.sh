#!/bin/bash

devname=$1

if test $(grep $devname /tmp/usbdevinfo | wc -l) -gt 0
then
	sed -n /$devname/!p /tmp/usbdevinfo
	
	if test $(wc -l /tmp/usbdevinfo) -eq 0 then
		rm /tmp/usbdevinfo
	fi
fi
