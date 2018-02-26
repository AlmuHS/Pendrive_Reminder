#!/bin/bash

#Script linked to 10-inhibit-shutdown polkit rule
#Notifies user if polkit rule locks shutdown (there are any usb device storage in the system)

#The script receives as parameter the user name, and calls notify-send command to notify user

#ADVICE: THIS SCRIPT ISN'T READY TO PRODUCTION
#The notification isn't shows in user screen 

#Get username from first parameter
user=$1

#Creates and export display environment variables.
#This variables will be used by notify-send to shows message in user desktop environment

export DISPLAY=":0" #Display number
export XAUTHORITY="/home/$user/.Xauthority" #Cookie file

#To send notification to user, we need to use the user account who we wants to show notification 
#To get this, we will use pkexec command

#The notification is disabled because it produce lags to show shutdown menu
#pkexec --user $user notify-send  "Pendrive Reminder" "Shutdown lock enabled. Disconnect pendrive to enable shutdown"

exit 0


