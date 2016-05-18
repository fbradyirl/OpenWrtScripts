#!/bin/sh

# Script to monitor a file and notify
# push services if that file changes
# here, we are monitoring the openvpn
# status file in case of new connections

# To start this file on boot,
# To run it at startup run command
# echo 'sh status_watcher.sh &' >> /etc/rc.local 

SLEEPTIME=30

# Assuming this is run on boot, the status files will be 
# empty. Storing this, so that we can see when
# all connections are gone.
ZERO_CONNECTIONS_HASH="$(openvpn-status.sh | md5sum)"
OLD_CONNECTIONS_HASH=''
while true; do
	NEW_CONNECTIONS_HASH="$(openvpn-status.sh | md5sum)"
	if [ "$NEW_CONNECTIONS_HASH" == "$ZERO_CONNECTIONS_HASH" ] ; then
                echo "Zero connection detected"
                echo "Sleeping for $SLEEPTIME seconds..."
                sleep $SLEEPTIME		
	elif [ "$NEW_CONNECTIONS_HASH" != "$OLD_CONNECTIONS_HASH" ] ; then
		echo "New connection detected"
		push.sh "$HOSTNAME VPN Update" "$(openvpn-status.sh)"
		OLD_CONNECTIONS_HASH="$NEW_CONNECTIONS_HASH"
	else
		echo "No updates to openvpn status file."
		echo "Sleeping for $SLEEPTIME seconds..."
		sleep $SLEEPTIME
	fi
done
