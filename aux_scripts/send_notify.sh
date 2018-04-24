#!/bin/bash

#Script linked to 10-inhibit-shutdown polkit rule
#Notifies user if polkit rule locks shutdown (there are any usb device storage in the system)

#The script use dbus-send command to send message to user using system bus and org.preminder service.
#The user will receive message to a dbus client connected org.preminder service

#send message to client using dbus system bus
dbus-send --system /org/preminder/$1 org.preminder.App

exit 0


