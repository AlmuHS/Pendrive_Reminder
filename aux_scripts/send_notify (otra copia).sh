#!/usr/bin/python2

import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify
Notify.init("test")
Notify.Notification.new("Hello friend, from python").show()

