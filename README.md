# OpenWrtScripts
General Scripts I use in OpenWRT


## INSTALLATION OpenVPN status watcher
```
opkg install curl
wget -O /etc/config/push http://rawgit.com/fbradyirl/OpenWrtScripts/master/push.conf
wget -O /usr/bin/push.sh http://rawgit.com/fbradyirl/OpenWrtScripts/master/push.sh
wget -O /usr/bin/status_watcher.sh http://rawgit.com/fbradyirl/OpenWrtScripts/master/status_watcher.sh
wget -O /usr/bin/openvpn-status.sh http://rawgit.com/fbradyirl/OpenWrtScripts/master/openvpn-status.sh

chmod +x /usr/bin/push.sh
chmod +x /usr/bin/status_watcher.sh
chmod +x /usr/bin/openvpn-status.sh

echo 'sh status_watcher.sh &' >> /etc/rc.local 
```
Now, just fill in required fields in /etc/config/push
