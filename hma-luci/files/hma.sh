#!/bin/sh

URL="http://hidemyass.com/vpn-config/vpn-config.zip"
SRCFILE=$(basename $URL)
TMPFILE="/etc/openvpn/$SRCFILE"
LOCKFILE="/tmp/hma.lock"
SRVLIST="/etc/openvpn/hma.list"

logger -t HMA "Started update script"

if [ -f $LOCKFILE ]; then
	logger -t HMA "Update already running: aborting"
	exit 0
fi

touch $LOCKFILE

logger -t HMA "Started update download"
rm "$TMPFILE"
wget-ssl --no-check-certificate "$URL" -O "$TMPFILE"
logger -t HMA "wget $URL: $?"

# Remove broken zipfile
unzip -t "$TMPFILE" || rm "$TMPFILE"

if [ -f $TMPFILE ]; then
  unzip -l "$TMPFILE" | grep ".ovpn" | awk '{ print $4 }' | sed 's/.ovpn//' > "$SRVLIST"
fi

rm $LOCKFILE

logger -t HMA "Finished update script"

exit 0
