#!/bin/sh

# The purpose of this script is to forward all incoming SMS
# to any relavent push notification services which might be 
#configured

# INSTALLATION:
# Copy this file to /usr/lib/sms/forwardsms.sh
#
# Now, as of ROOter GoldenOrb release (1/Apr/2016)
# you must insert the following lines between 
# "uci commit modem" and "fi" of the loop 
# in file /usr/lib/sms/processsms 

#if [ -e /usr/lib/sms/forwardsms.sh ]; then
#	sh /usr/lib/sms/forwardsms.sh $CURRMODEM
#fi

log() {
	echo "forwardsms.sh: $@"
        logger -t "forwardsms.sh" "$@"
}

CURRMODEM=$1
lua /usr/lib/sms/smsread.lua $CURRMODEM
#smsread.lua writes list of decoded SMS messages to file /tmp/smstext 

SUBJECT="$HOSTNAME got new SMS"
SMSTEXT=`grep -B 1 "["$'\xe2\x9a\x91'"]" /tmp/smstext`

# To prevent a notify on first boot
# create a hash to remember first run
HASH_FILE=/tmp/sms_hash.txt
if [ -e $HASH_FILE ]; then
	read BOOT_SMS_HASH < $HASH_FILE
else
	BOOT_SMS_HASH="$(echo $SMSTEXT | md5sum)"
fi

NEW_SMS_HASH="$(echo $SMSTEXT | md5sum)"
echo "$(echo $SMSTEXT | md5sum)" > $HASH_FILE

#log "NEW_SMS_HASH: $NEW_SMS_HASH"
#log "BOOT_SMS_HASH: $BOOT_SMS_HASH"

if [ "$NEW_SMS_HASH" == "$BOOT_SMS_HASH" ] ; then
	log "No new SMS found."
else
	log "Forwarding new SMS on modem $CURRMODEM to push services"
	push.sh "$SUBJECT" "$SMSTEXT"
fi
