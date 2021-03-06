#!/bin/bash

#Script linked to udev rule

#Generates a watchdog file, adding the id of usb storage device when it is connected
#The watchdog file will be in /tmp/usbdevinfo

#In polkit version < 0.106, this script also copy polkit pkla file to add polkit rule
#This polkit rule locks the shutdown while usb storage devices are connected to the machine


#Copy USB identifier in usbdevinfo watchdog file.
#This file will be used to detect if there are any usb storage device connected to the machine
DEVPATH=$1
echo $DEVPATH >> /tmp/usbdevinfo


#When first usb device is connected
if test $(wc -l /tmp/usbdevinfo | cut -d " " -f 1) -eq 1
then
	#Path to installation directory
	INSTALL_DIR="/usr/bin/pendrive-reminder"

	#Export env variables for gettext
	export TEXTDOMAIN="preminder"
	export TEXTDOMAINDIR="/usr/share/locale"
	export LANG=$(grep LANG $INSTALL_DIR/var | cut -d "=" -f 2)

	#Get list of users with graphic session started, and their active display 
	userdisplay=$(who | gawk '/\(:[[:digit:]](\.[[:digit:]])?\)/ { print $1 ";" substr($NF, 2, length($NF)-2) }' | uniq)

	if test -z $userdisplay
	then
		disp=$(grep DISPLAY $INSTALL_DIR/var | cut -d "=" -f 2)
		userdisplay=$(who | cut -d " " -f 1 | gawk -v var=$disp '{print $1 ";" var}')
	fi
	
	#Get polkit version
	polkit_version=$(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2)

	if test $polkit_version -ge 106
	then
		#creates a temporary file, to save pid of dbus clients
		touch /tmp/pid_dbus
		chmod 666 /tmp/pid_dbus

	#In polkit version < 0.106, the rules file don't run, so we need to copy authority files	
	else
		#copy pkla file in localauthority directory		
		cp $INSTALL_DIR/50-inhibit-shutdown.pkla /etc/polkit-1/localauthority/50-local.d/
		service polkit restart	
	fi

	#get message translation
	export message1=$(gettext "Shutdown lock enabled. ")
	export message2=$(gettext "The shutdown will be unlocked when pendrive is disconnected")

	#for each user, show notification and (only in polkit >= 106) launch dbus client 
	for element in $userdisplay
	do			
		#get username		
		user=$(echo $element | cut -d ";" -f 1)
		
		#get display active of this user		
		export DISPLAY=$(echo $element | cut -d ";" -f 2)		
		
		#Show notification translated
		su $user -c 'notify-send "Pendrive Reminder" "$message1 $message2"'

		#if polkit version >=106, also launch dbus client
		if test $polkit_version -ge 106
		then
			#To avoid udev lock after launch dbus client, launch client as task

			#Creates a temporary file, with commands to launch in the task 
			echo "export DISPLAY=$DISPLAY" > at_task
			echo "export LANG=$LANG" >> at_task
			echo "/usr/bin/pendrive-reminder/dbus-client/client.py $user &" >> at_task

			#creates another temporary file, to save pid of dbus clients
			echo 'echo $! >> /tmp/pid_dbus' >> at_task
			
			#Launch task with at command
			su $user -c 'at -f at_task now'
		fi
	done

	if test $polkit_version -ge 106
	then
		#Get num of active users, to wait until all writes are done
		userdisplay=( $userdisplay )
		num_users=${#userdisplay[@]}

		#wait to write in the file
		while test $(wc -l /tmp/pid_dbus | cut -d " " -f 1) -lt $num_users		
		do
			:
		done

		#Set pid_dbus file in root read-only mode
		chmod 400 /tmp/pid_dbus

		#delete at_task temporary file
		rm at_task
	fi
fi

exit 0

