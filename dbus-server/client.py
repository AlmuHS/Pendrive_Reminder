#!/usr/bin/python3

#Original code from https://stackoverflow.com/questions/22390064/use-dbus-to-just-send-a-message-in-python

from gi.repository import Gtk
import dbus
from dbus.mainloop.glib import DBusGMainLoop
import notify2

DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()

def msg_handler(*args,**keywords):
    try:
        #show notification to desktop
        notify2.init('Pendrive Reminder')
        notify = notify2.Notification('Pendrive Reminder', 'Shutdown lock enabled. Disconnect pendrive to enable shutdown')
        notify.show()
    except:
        pass

bus.add_signal_receiver(handler_function=msg_handler, dbus_interface='org.preminder', path_keyword='path')
Gtk.main()
