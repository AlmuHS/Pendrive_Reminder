#!/bin/bash

#Remove scripts folder
rm -r /usr/bin/pendrive-reminder

#Remove udev rules
udev_files=$(ls udev-rules)

cd /etc/udev/rules.d/
rm $udev_files

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

