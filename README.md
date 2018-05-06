# Pendrive_Reminder
Pequeña herramienta para no olvidar el pendrive, para GNU/Linux

## Introducción
Esta herramienta tiene como intención hacer de recordatorio a la hora de usar tu pendrive en un PC ajeno.
El funcionamiento es muy simple: si intentas apagar el ordenador con el pendrive conectado, la herramienta te mandará un aviso, y te bloqueará el apagado hasta que desconectes el pendrive

## Requisitos
- Sistema Operativo GNU/Linux
- polkit
- udev
- libnotify
- cron (solo si la versión de Polkit es < 0.106)
- dbus
- Python 3
    - python-dbus
    - pygobject
 - at
 - gettext

## Implementación

### Udev
Para nuestra herramienta, se han usado dos reglas udev, asociadas a los eventos de conexión y desconexión de un dispositivo USB.

- La primera regla udev, [`10-usbmount.rules`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/udev-rules/10-usbmount.rules), al detectar el evento de conexión de un dispositivo de almacenamiento USB, invocará al script [`usbdevinserted.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevinserted.sh). Este script escribirá el identificador del USB en un fichero, creándolo en caso de no existir.
Este fichero nos servirá de testigo para saber si queda algún dispositivo de almacenamiento USB conectado en el sistema.

	Como identificador usaremos la variable `DEVPATH` asociada al dispositivo, y el fichero generado estará ubicado en `/tmp/usbdevinfo`


- La segunda regla udev,[`11-usbdisconnect.rules`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/udev-rules/11-usbdisconnect.rules), detectará el evento de desconexión del dispositivo USB, e invocará al script [`usbdevgone.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevgone.sh). que buscará el identificador del dispositivo en el fichero testigo y, en caso de existir, lo borrará. Una vez borrado el identificador, si el fichero está vacío (no queda ningún dispositivo conectado) borrará el fichero.

	Dadas las diferencias entre distribuciones, esta segunda regla udev se ha asociado a dos eventos distintos: `unbind` y `remove`, que representan el evento de desconexión en diferentes distribuciones.

### Polkit
Añadido a las reglas udev, también se han creado dos reglas polkit. Estas servirán para detectar el evento de apagado y denegar la autorización para el mismo, en caso de que haya algún dispositivo de almacenamiento USB conectado.

Debido a las diferencias entre las versiones 0.106 (que admite ficheros .rules en javascript) y las anteriores (que funcionan con ficheros de autorización) se han seguido dos implementaciones para este comportamiento:


- Para las versiones modernas de polkit (>= 0.106), se ha usado un fichero .rules ([`10-inhibit-shutdown.rules`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/polkit-rules/10-inhibit-shutdown.rules)) que, al detectar el evento de apagado, invoca a un script ([`check_pendrive.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/check_pendrive.sh)) que indica si el fichero testigo existe en el sistema, devolviendo 0 (correcto) en caso de que no exista y 1 (error) en caso de que exista.

	En caso de error, se deniega el permiso, y se invoca a otro script ([`send_notify.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/send_notify.sh)) que envía una notificación al usuario, indicando que debe desconectar el pendrive para poder apagar el ordenador.
	
- Para las versiones antiguas de polkit (< 0.106), se ha usado un fichero de autorización .pkla ([`50-inhibit-shutdown.pkla`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/polkit-rules/50-inhibit-shutdown.pkla)).
		Este fichero será copiado por el script [`usbdevinserted.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevinserted.sh) durante el evento de conexión del pendrive. Al copiarlo, se activará el bloqueo del apagado.
		Una vez el pendrive se desconecte, el script [`usbdevgone.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevgone.sh), en caso de que no quede ningún dispositivo conectado, borrará el fichero de autorización para desactivar el bloqueo.
		
    También, para el caso extremo de que el usuario fuerce el apagado del sistema con el pendrive conectado (a traves de línea de   comandos u otros métodos), se ha añadido una tarea cron que, al iniciar el sistema, comprueba si el fichero testigo existe, y en  caso contrario, borra el fichero de autorización (en caso de que este aún exista en el sistema)
		
Dadas las diferencias entre distribuciones y/o entornos de escritorio, estas reglas polkit estan asociadas varios eventos distintos: `org.freedesktop.consolekit.system.stop`, `org.freedesktop.login1.power-off`, `org.freedesktop.login1.power-off-multiple-sessions` y `org.xfce.session.xfsm-shutdown-helper` 

### Dbus

Para que polkit pueda envíar una notificación al usuario, se usará un servidor dbus (`org.preminder`), al cual estará conectado un cliente [`client.py`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/dbus-client/client.py) propiedad del usuario.

De esta forma, cuando polkit deniegue el permiso para apagar el sistema, el script [`send_notify.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/send_notify.sh) enviará una señal, usando el bus del sistema, al servicio `org.preminder`. El cliente de este servicio recibirá la señal y mostrará el mensaje al usuario.

El cliente dbus será lanzado por el script [`usbdevinserted.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevinserted.sh), asociado a la regla udev [`10-usbmount.rules`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/udev-rules/10-usbmount.rules); y posteriormente eliminado por [`usbdevgone.sh`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/aux_scripts/usbdevgone.sh), asociado a la regla udev [`11-usbdisconnect.rules
`](https://github.com/AlmuHS/Pendrive_Reminder/blob/master/udev-rules/11-usbdisconnect.rules)


## Comportamiento
El comportamiento de la herramienta dependerá de la versión de polkit usada por el sistema, y de la distribución y entorno de escritorio donde se ejecute.

Al conectar y desconectar el pendrive, se emitirá una notificación indicando que el bloqueo de apagado se ha activado o desactivado.

Según el entorno de escritorio y la distribución, la opción de apagado desaparecerá del menú de apagado, o simplemente se mantendrá pero sin asociarse a ninguna acción (al pulsarse no hace nada).

Además, si la versión de polkit es >= 0.106, al abrir el menú de apagado con el pendrive conectado, se enviará una notificación indicando que debe desconectar el pendrive para desbloquear el apagado

El bloqueo del apagado se mantendrá mientras haya algún pendrive conectado al equipo.

En todos los casos, el sistema volverá a la normalidad, desbloqueando el apagado, al desconectar todos los pendrives.


### Localización

La herramienta cuenta con soporte de localización en diferentes idiomas. Cuando la herramienta se instale, detectará el idioma del sistema y lo utilizará como lengua por defecto para las notificaciones. En caso de no disponer de traducción para dicho idioma, la herramienta seleccionará inglés como idioma principal.

Los idiomas actualmente soportados son:

- Inglés
- Francés
- Español
- Gallego
- Neerlandés
- Portugués
- Italiano
- Catalán

### Accesibilidad

La herramienta también cuenta con soporte para asistentes de accesibilidad, como lectores de pantalla (probado con el lector de pantalla Orca), letras grandes y pantalla ampliada.

La localización permite que el texto sea leído en el mismo idioma del usuario, lo cual ayuda a entender mejor el mensaje a través de asistentes como el lector de pantalla.


## Instalación

Para instalar la herramienta, únicamente hay que descargar el repositorio y ejecutar el script de instalación.
En el caso de las distribuciones que usan polkit >= 0.106, también hay que instalar las dependencias del cliente dbus.

- Instalación de dependencias

    - **Debian\*/Ubuntu (y derivados)**:
    
        `sudo apt install libnotify-bin policykit-1`
	
	  \* **NOTA**: En Debian es posible instalar polkit 0.114, desde el repositorio experimental, siguiendo estas [instrucciones](https://github.com/AlmuHS/Pendrive_Reminder/wiki/Instalar-Polkit-0.114-en-Debian)

	
    - **Ubuntu 17.10**:
    
       `sudo apt install libnotify-bin policykit-1 udev`        

    - **Fedora**:
     
      `sudo dnf install dbus-python pygobject3 python3-gobject at libnotify`

    - **Arch Linux**:

      `sudo pacman -S python-dbus python-gobject at libnotify`

    - **Gentoo**:
 
      `sudo emerge -a dev-python/dbus-python dev-python/pygobject sys-process/at x11-libs/libnotify`

- Para descargar, se puede usar `git` con el comando:

	`git clone https://github.com/AlmuHS/Pendrive_Reminder.git`
	
- Una vez descargado, para instalarlo hay que ejecutar:

	`cd Pendrive_Reminder`
	
	`sudo ./installer.sh`

### Directorios de instalación

Los scripts y el cliente dbus se copiarán en el directorio `/usr/bin/pendrive-reminder`. 

La regla polkit se copiará en `/usr/share/polkit-1/rules.d/` en caso de polkit >= 0.106. 
En caso de polkit < 0.106, el fichero .pkla se ubicará temporalmente en `/usr/bin/pendrive-reminder` y, una vez conectado el pendrive, se copiará a `/etc/polkit-1/localauthority/50-local.d/`, de donde se borrará una vez se desconecte el pendrive.

Las locales se instalarán en `/usr/share/locales`, dentro del subdirectorio del idioma correspondiente

## Desinstalación

Para desinstalar la aplicación, simplemente hay que irse al directorio donde se ha descargado la herramienta, y ejecutar:

    sudo ./uninstaller.sh

El desinstalador eliminará el directorio de instalación y todos los ficheros de reglas y locales existentes en el sistema.

La desinstalación se puede realizar "en caliente", mientras la herramienta está activa. 
En dicho caso, el desinstalador, además de lo anterior, también eliminará todos los ficheros temporales creados, el fichero de autorización, y matará todos los procesos iniciados por la herramienta. 

Las dependencias, instaladas de forma previa a la instalación, NO serán eliminadas.

## Distribuciones testeadas:
### Polkit < 0.106
- Debian 9 y 10, GNOME (v0.105): :heavy_check_mark:
- Debian 9 KDE (v0.105) :bangbang: : Encontrado [bug](https://github.com/AlmuHS/Pendrive_Reminder/issues/9) en bloqueo y desbloqueo de apagado
- MAX 9 MadridLinux (v0.105)  :heavy_check_mark:
- Bodhi Linux  :x:
- Linux Mint Xfce: :heavy_check_mark:
- Guadalinex Edu Slim :heavy_check_mark: : Entorno de escritorio LXDE 
- Lubuntu 14.04.1: :heavy_check_mark:
- Lubuntu 17.10.1: :heavy_check_mark:
- Ubuntu 18.04: :heavy_check_mark: : Probado en GNOME bajo Xorg

(En desarrollo)

### Polkit >= 0.106
- Gentoo (v0.106) :heavy_check_mark: : Probada en entorno Cinnamon, con sistema de inicio OpenRC
- Arch Linux (v0.115)  :bangbang: : Probada en entorno KDE. Encontrado [bug](https://github.com/AlmuHS/Pendrive_Reminder/issues/7)
- Fedora 27: :heavy_check_mark: : Probada en GNOME bajo Xorg y Wayland. Pequeño [bug](https://github.com/AlmuHS/Pendrive_Reminder/issues/8) en Wayland al mostrar notificaciones

(En desarrollo)

## Contribuidores
- [maxezek](https://github.com/maxezek): Testeo de la herramienta en MAX 9 MadridLinux
- [lendulado](https://github.com/lendulado): Ayuda con expresiones regulares, testeo de la herramienta en Debian 9, y reporte de errores en el instalador
- [oxcar103](https://github.com/oxcar103): Testeo de la herramienta en Bodhi Linux
- Fabio Natalini: Testeo de la herramienta en Linux Mint Xfce 
- [acaso](https://github.com/acaso), [Lt-Henry](https://github.com/Lt-Henry): Ayuda con dbus
- [aledomu](https://github.com/aledomu): Ayuda con polkit
- [alo-malvarez](https://es.stackoverflow.com/users/81450/alo-malbarez): Ayuda en lanzamiento cliente dbus desde udev
- [RafaelAybar](https://github.com/RafaelAybar): Testeo de la herramienta en Fedora 27
- [RicardoMoreno](https://github.com/RicardoMoreno): Testeo de la herramienta en Debian 9 KDE, traducción al italiano
- [homero10](https://github.com/homero10): Testeo de la herramienta en Guadalinex y Ubuntu 17.10
- [Makova](https://github.com/Makova): Testeo de la herramienta en Ubuntu 18.04
- [javihernandez](https://github.com/javihernandez): Sugerencias y ayuda en localización
- [Foxandxss](https://github.com/Foxandxss): Sugerencias y ayuda en localización. Traducción al neerlandés y portugués
- [delightfulagony](https://github.com/delightfulagony), [RNogales94](https://github.com/RNogales94): Traducción al francés
- [Noel](https://github.com/BreoganGal): Traducción al gallego
- [DrGus](https://github.com/DrGus): Traducción al catalán
