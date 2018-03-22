#!/bin/bash

INSTALL_DIR="/usr/bin/pendrive-reminder"

#Copy auxiliar scripts
mkdir $INSTALL_DIR 2>/dev/null
cp aux_scripts/* $INSTALL_DIR
chmod +x $INSTALL_DIR/*.sh

#copy udev rules and recharge udev
cp udev-rules/* /etc/udev/rules.d/
udevadm control --reload-rules

#Copy polkit rules

#If polkit version is >= 0.106
if test $(pkaction --version | cut -d " " -f 3 | cut -d "." -f 2) -ge 106
then
	#copy rules file	
	cp polkit-rules/10-inhibit-shutdown.rules /usr/share/polkit-1/rules.d/

	#copy dbus-client
	cp dbus-client/client.py $INSTALL_DIR

	#Download python pip
	wget https://bootstrap.pypa.io/get-pip.py

	#get user list
	USER_LIST=$(grep /home /etc/passwd | cut -d: -f1)

	#For each user, install pip and use it to install dependencies
	for user in $USER_LIST
	do
		#Install python pip
		su $user -c 'python get-pip.py --user'
		su $user -c 'pip install --upgrade pip'

		#Install dependencies for dbus python client
		su $user -c 'pip install pygobject notify2 --user'
	done

#If polkit version is < 0.106
else
	#if polkit version is < 0.106 copy pkla file to a temporal directory
	cp polkit-rules/50-inhibit-shutdown.pkla $INSTALL_DIR

	#Add cron task to remove shutdown lock after forced shutdown or reboot
	(crontab -l 2>/dev/null; echo "@reboot $INSTALL_DIR/check_shutforced.sh") | crontab -
fi

#check linux distribution
distro=$(grep '^ID=' /etc/os-release | cut -d = -f 2)

#if distribution is Debian or Ubuntu, install libnotify
if test "$distro" = "debian" || test "$distro" = "ubuntu" || test "$distro" = "linuxmint"
then
	apt install libnotify-bin
fi


