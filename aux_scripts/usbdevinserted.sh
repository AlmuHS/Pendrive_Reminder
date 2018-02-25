#!/bin/bash

#Copy USB identifier in usbdevinfo file.
#This file will be used to detect if there are any usb storage device connected to the machine
set 2>&1 | grep DEVPATH | cut -d "=" -f 2 >> /tmp/usbdevinfo


#In polkit version < 0.106, the rules file don't run, so we need to use the old method
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -lt 106
then

	#Check is pkla file exists in localauthority directory	
	if ! test -f /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla
	then
		#If it don't exists, copy pkla file in localauthority directory		
		cp /usr/bin/pendrive-reminder/50-inhibit-shutdown.pkla /etc/polkit-1/localauthority/50-local.d/
	fi
	
	#Restart service
	service polkit restart
fi


#Notify all connected users
user_list=$(who | cut -d " " -f 1)

for user in $user_list
do
	export DISPLAY=":0"	
	su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock enabled. The shutdown will be unlocked when pendrive is disconnected" -u critical'
done
