#!/bin/bash



user=$1

export DISPLAY=":0"
export XAUTHORITY="/home/$user/.Xauthority"

echo $user $XAUTHORITY > /tmp/user
cat $XAUTHORITY > /tmp/Xauth

pkexec --user $user notify-send  "Pendrive Reminder" "Shutdown lock enabled. Disconnect pendrive to enable shutdown"

exit 0


