#!/bin/bash

set 2>&1 | grep DEVPATH | cut -d "=" -f 2 >> /tmp/usbdevinfo
