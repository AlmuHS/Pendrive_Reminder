#!/bin/bash

devname=$1

echo $devname > /tmp/devname		

sed -i "%|${devname}.*|%d" /tmp/usbdevinfo

if test $(wc -l /tmp/usbdevinfo) -eq 0 then
	rm /tmp/usbdevinfo
fi

