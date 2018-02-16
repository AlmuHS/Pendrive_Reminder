#!/bin/bash

if test -f "/tmp/usbdevinfo" 
then
	exit -1
else
	exit 0
fi
