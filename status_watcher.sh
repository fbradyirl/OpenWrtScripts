#!/bin/sh

# Script to monitor a file and notify
# push services if that file changes
# here, we are monitoring the openvpn
# status file in case of new connections

# To start this file on boot,
# To run it at startup run command
# echo 'sh status_watcher.sh &' >> /etc/rc.local 

log() {
        echo "status_watcher.sh: $@"
        logger -t "status_watcher.sh" "$@"
}

SLEEPTIME=60

# Assuming this is run on boot, the status files will be 
# empty. Storing this, so that we can see when
# all connections are gone.
ZERO_CONNECTIONS_HASH="$(openvpn-status.sh | md5sum)"
OLD_CONNECTIONS_HASH=''

while true; do
	NEW_CONNECTIONS_HASH="$(openvpn-status.sh | md5sum)"

	#log "NEW_CONNECTIONS_HASH: $NEW_CONNECTIONS_HASH"
	#log "ZERO_CONNECTIONS_HASH: $ZERO_CONNECTIONS_HASH"
	#log "OLD_CONNECTIONS_HASH: $OLD_CONNECTIONS_HASH"

	if [ "$NEW_CONNECTIONS_HASH" == "$ZERO_CONNECTIONS_HASH" ] ; then
                log "Zero new openvpn connections detected. Sleeping for $SLEEPTIME seconds..."
                sleep $SLEEPTIME		
	elif [ "$NEW_CONNECTIONS_HASH" != "$OLD_CONNECTIONS_HASH" ] ; then
		log "OpenVPN connection change detected"
		push.sh "$HOSTNAME VPN Update" "$(openvpn-status.sh)"
		OLD_CONNECTIONS_HASH="$NEW_CONNECTIONS_HASH"
	else
		log "No updates to openvpn status file."
		log "Sleeping for $SLEEPTIME seconds..."
		sleep $SLEEPTIME
	fi
done
