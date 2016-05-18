#!/bin/sh

# Fill the following in to match your OpenVPN config
STATUS_TCP="$(uci get openvpn.TCPVPNserver.status)"
STATUS_UDP="$(uci get openvpn.UDPVPNserver.status)"
SUBNET_TCP="10.2"
SUBNET_UDP="10.1"

OLDIFS=$IFS

# Use for JSON parsing
. /usr/share/libubox/jshn.sh

printIPs () {

	IFS=:,
	var="$(cat $1 | grep  client | grep -v $SUBNET_TCP  | grep -v $SUBNET_UDP)"
	ip_port="$(echo $var | awk '{ print $0 }')"

	if [ "$ip_port" != "" ]; then
		ips="$(echo $ip_port | awk '{ print $2 }')"

   		IFS=$'\n'

		for ip in $ips
		do
		json=$(curl http://freegeoip.net/json/$ip ; echo)
		json_load "$json"
		json_get_var country country_name

		if [ "$country" != "" ]; then
			country=" ($country)"
		fi;		

                dname=$(nslookup $ip | grep ^Name -A1| awk '{print $4}' | tr '\n' ' ')		
                if [ "$dname" != "" ]; then
                        dname=" ($dname)"
                fi;

		echo "->ip: $ip$country$dname"
		done
	fi;

	IFS=$OLDIFS	
}

echo "OpenVPN tunnels:"
COUNT="$(cat $STATUS_TCP | grep  client | grep -v $SUBNET_TCP  | grep -v $SUBNET_UDP | wc -l)"
echo "TCP: ${COUNT}"

printIPs $STATUS_TCP

COUNT="$(cat $STATUS_UDP | grep  client | grep -v $SUBNET_TCP  | grep -v $SUBNET_UDP | wc -l)" 
echo "UDP: ${COUNT}" 

printIPs $STATUS_UDP
