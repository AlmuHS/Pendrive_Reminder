#!/usr/bin/python3

#Original code from https://stackoverflow.com/questions/22390064/use-dbus-to-just-send-a-message-in-python


#Python DBUS Test Server
#runs until the Quit() method is called via DBUS

from gi.repository import Gtk
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop

DBUS_NAME = 'org.preminder'
DBUS_PATH = '/org/preminder'


class MyDBUSService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(DBUS_NAME, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, DBUS_PATH)

    @dbus.service.method(DBUS_NAME)
    def hello(self):
        """returns the message'"""
        return "Unconnect pendrive to enable shutdown"

    @dbus.service.method(DBUS_NAME)
    def string_echo(self, s):
        """returns whatever is passed to it"""
        return s

    @dbus.service.method(DBUS_NAME)
    def Quit(self):
        """removes this object from the DBUS connection and exits"""
        self.remove_from_connection()
        Gtk.main_quit()
        return

DBusGMainLoop(set_as_default=True)
myservice = MyDBUSService()
Gtk.main()
