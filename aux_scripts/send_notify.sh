#!/bin/bash

user=$(who | tail | cut -d " " -f 1)
su $user -c 'notify-send "Pendrive Reminder" "Shutdown lock enabled. Disconnect pendrive to enable shutdown" -u critical'

