#!/bin/sh

TOR_FW="/etc/tor/tor.firewall"
USR_FW="/etc/firewall.user"
OLD_FW="/etc/firewall.user.old"
TOR_SCRIPT="/etc/init.d/tor"

case "$1" in
    start|restart|reload|force-reload)
	cat /etc/tor/torrc.base /etc/tor/proxy /etc/tor/bridges > /etc/tor/torrc
	$TOR_SCRIPT start
	if [ ! -f /etc/rc.d/S50tor ]; then
		$TOR_SCRIPT enable
	fi
	if [ ! -f $OLD_FW ]; then
		logger -t TOR "Replace user fw script with tor fw script"
		# Save user fw script
		cp $USR_FW $OLD_FW
		# Replace with tor fw script
		cp -f $TOR_FW $USR_FW
	fi
	/etc/init.d/firewall reload
	;;
    stop)
	$TOR_SCRIPT stop
	$TOR_SCRIPT disable
	if [ -f $OLD_FW ]; then
		# Update tor fw script
		#cp -f $USR_FW $TOR_FW 
		logger -t TOR "Restore user fw script"
		mv -f $OLD_FW $USR_FW
	fi
	/etc/init.d/firewall reload
	;;
    *)
        echo "Usage: $0 start|stop|reload" >&2
        exit 3
        ;;	
esac
