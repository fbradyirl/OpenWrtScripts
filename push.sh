#!/bin/sh

log() {
        echo "push.sh: $@"
        logger -t "push.sh" "$@"
}

SUBJECT="$1"
MSG="$2"

################
# PushBullet
################

PB_ENABLED=$(uci get push.pushbullet.enabled)
API=$(uci get push.pushbullet.push_api)

if [ $PB_ENABLED == 1 ]; then
	if [ ! -z $API ]; then
  		curl -k -u $API: https://api.pushbullet.com/v2/pushes -d type=note -d title="$SUBJECT" -d body="$MSG" > /dev/null 2>&1
	else
  		log "Set your PushBullet API key in /etc/config/push"
	fi
fi

################
# Cisco Spark
################

SPARK_AUTH=$(uci get push.ciscospark.auth_token)
SPARK_UUID=$(uci get push.ciscospark.dest_uuid)
SPK_ENABLED=$(uci get push.ciscospark.enabled)

if [ $SPK_ENABLED == 1 ]; then
	if [ ! -z $SPARK_AUTH ]; then
        	# Send a message to me via Cisco Spark
		SPARK_MSG="$SUBJECT
	
		$MSG"
        	curl -k https://api.ciscospark.com/v1/messages -X POST -H "Authorization:Bearer $SPARK_AUTH" --data "toPersonId=$SPARK_UUID" --data-urlencode "text=$SPARK_MSG"  > /dev/null 2>&1
	else
		log "Set your Cisco Spark AUTH token in /etc/config/push"
	fi
fi
