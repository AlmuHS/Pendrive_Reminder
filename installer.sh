#!/bin/bash

INSTALL_DIR="/usr/bin/pendrive-reminder"

#Copy auxiliar scripts
mkdir $INSTALL_DIR 2>/dev/null
cp -r aux_scripts/ $INSTALL_DIR
chmod +x $INSTALL_DIR/aux_scripts/*

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
	cp -r dbus-client/ $INSTALL_DIR
	chmod ugo+x $INSTALL_DIR/dbus-client/client.py

#If polkit version is < 0.106
else
	#if polkit version is < 0.106 copy pkla file to a temporal directory
	cp polkit-rules/50-inhibit-shutdown.pkla $INSTALL_DIR

	#Add cron task to remove shutdown lock after forced shutdown or reboot
	(crontab -l 2>/dev/null; echo "@reboot $INSTALL_DIR/check_shutforced.sh") | crontab -
fi

#check linux distribution
distro=$(grep '^ID=' /etc/os-release | cut -d = -f 2)
version=$(grep "VERSION_ID" /etc/os-release | cut -d "=" -f 2)

#if distribution is Ubuntu or Linux Mint, restart udev
if test "$distro" = "ubuntu" && test "$version" = "\"17.10\""
then
	systemctl restart udev
fi

  
