#!/bin/bash

#If script is executed as non-root user, reject
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
else
	#Remove scripts folder
	if test -d /usr/bin/pendrive-reminder
	then
		rm -rf /usr/bin/pendrive-reminder
	fi

	#Remove udev rules
	udev_files=$(ls udev-rules)

	cd /etc/udev/rules.d/
	rm $udev_files 2>/dev/null

	#Remove locale files
	find /usr/share/locale/ -name "preminder*" -delete

	#If polkit version is >= 0.106, remove rules and policy file	
	if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
	then
		rm /usr/share/polkit-1/rules.d/10-inhibit-shutdown.rules
		
		#if there are any dbus client active, kill them
		if test -f /tmp/pid_dbus
		then
			while read pid
			do
				kill -9 $pid
			done < /tmp/pid_dbus

			#Remove temporary file
			rm /tmp/pid_dbus
		fi

	#if polkit < 0.106, remove pkla file and cron task
	else
		rm /etc/polkit-1/localauthority/50-local.d/50-inhibit-shutdown.pkla 2>/dev/null
		crontab -l 2>/dev/null | grep -v '/usr/bin/pendrive-reminder/check_shutforced.sh'  | crontab -
	fi

	if test -f /tmp/usbdevinfo
	then
		rm /tmp/usbdevinfo
	fi
fi
