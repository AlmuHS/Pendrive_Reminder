#!/usr/bin/python3

#Original code from https://stackoverflow.com/questions/22390064/use-dbus-to-just-send-a-message-in-python
#With helpful of Alberto Caso https://es.stackoverflow.com/a/148802/26469

from gi.repository import Gtk
from gi.repository import Notify
import dbus
from dbus.mainloop.glib import DBusGMainLoop

DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()

def msg_handler(*args,**keywords):
    try:
        #show notification to desktop
        Notify.init('Pendrive Reminder')
        notify = Notify.Notification.new('Pendrive Reminder', 'Shutdown lock enabled. Disconnect pendrive to enable shutdown')
        notify.show()
    except:
        pass

bus.add_signal_receiver(handler_function=msg_handler, dbus_interface='org.preminder', path_keyword='path')
Gtk.main()
