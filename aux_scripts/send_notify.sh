#!/bin/bash

#Script linked to 10-inhibit-shutdown polkit rule
#Notifies user if polkit rule locks shutdown (there are any usb device storage in the system)

#The script receives as parameter the user name, and calls notify-send command to notify user

#ADVICE: THIS SCRIPT ISN'T READY TO PRODUCTION
#The notification isn't shows in user screen 

#Get username from first parameter
user=$1

#send message to client using dbus system bus
dbus-send --system /org/preminder/mensaje org.preminder.App

exit 0


