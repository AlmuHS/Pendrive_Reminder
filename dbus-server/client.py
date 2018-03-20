#!/usr/bin/python3

#Original code from https://stackoverflow.com/questions/22390064/use-dbus-to-just-send-a-message-in-python

#Python script to call the methods of the DBUS Test Server

import dbus

DBUS_NAME = 'org.preminder'
DBUS_PATH = '/org/preminder'

#get the session bus
bus = dbus.SessionBus()
#get the object
the_object = bus.get_object(DBUS_NAME, DBUS_PATH)
#get the interface
the_interface = dbus.Interface(the_object, DBUS_NAME)

#call the methods and print the results
reply = the_interface.hello()
print(reply)

the_interface.Quit()
