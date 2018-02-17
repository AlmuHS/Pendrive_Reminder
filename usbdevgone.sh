#!/bin/bash

#USB Device identifier
devpath=$1 

#Path to USB identifiers list file
filepath="/tmp/usbdevinfo"

#if the USB's id is in the file, remove it
sed -in "\%${devpath}%d" $filepath

#After remove the id, check if file is empty
if ! test -s $filepath  
then
	#if file is empty, remove it
	rm $filepath
fi

