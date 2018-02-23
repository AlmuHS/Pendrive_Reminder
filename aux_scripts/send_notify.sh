#!/bin/bash

export DISPLAY=":0"

user=$1
su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock enabled. Disconnect pendrive to enable shutdown" -u critical'




