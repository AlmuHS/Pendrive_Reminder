#!/bin/bash

export XAUTHORITY="/home/$user/.Xauthority"
export DISPLAY=$(cat "/tmp/display.$user")

user=$1
su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock enabled. Disconnect pendrive to enable shutdown" -u critical'

