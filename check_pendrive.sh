#!/bin/bash

if ! test -e "/tmp/usbdevinfo" 
then
	exit 0
else
	exit 1
fi
