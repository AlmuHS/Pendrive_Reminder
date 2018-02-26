#!/bin/bash

#Script linked to #Script linked to 10-inhibit-shutdown polkit rule
#This script check if watchdog file exists in the system
#If don't exists, return 0 (correct)
#else return 1(error)


#Check if watchdog file exists
if ! test -e "/tmp/usbdevinfo" 
then
	#don't exists -> return correct	
	exit 0
else
	#exists -> return error
	exit 1
fi
