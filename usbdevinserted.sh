#!/bin/bash

set 2>&1 | grep DEVNAME | cut -d "=" -f 2 >> /tmp/usbdevinfo
