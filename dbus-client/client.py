#!/usr/bin/python3

#Original code from https://stackoverflow.com/questions/22390064/use-dbus-to-just-send-a-message-in-python
#With helpful of Alberto Caso https://es.stackoverflow.com/a/148802/26469

from gi.repository import GLib
from gi.repository import Notify
import dbus
from dbus.mainloop.glib import DBusGMainLoop
import logging
import logging.config
import pathlib
import sys

file = open('/home/almu/path.log', "w")
logging.basicConfig(filename='/home/almu/gettext.log')
logger = logging.getLogger(__name__)

file.write(str(sys.path))

#Start dbus mainloop
dbus_loop = DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus(mainloop=dbus_loop)
loop = GLib.MainLoop()

try:
    import gettext
except Exception as exec:
    logger.exception(exec)


#Install locale support
try:
    linguas = gettext.translation('preminder', localedir='/usr/share/locale', languages=['es'])
except Exception as exec:
    logger.exception(exec)

linguas.install()


def msg_handler(*args,**keywords):
    try:
        #show notification to desktop
        Notify.init('Pendrive Reminder')
        notify = Notify.Notification.new('Pendrive Reminder', _('Shutdown lock enabled. Disconnect pendrive to enable shutdown'))
        notify.show()
    except:
        pass

#Wait to dbus signal
bus.add_signal_receiver(handler_function=msg_handler, dbus_interface='org.preminder', path_keyword='path')
loop.run()

