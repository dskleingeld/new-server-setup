#!/usr/bin/env bash
set -e

# This script only sets up the user for the home automation service
# it does not compile the executable

DOMAIN=$1
TOKEN=$2
ADMIN_PASS=$3
HA_TOKEN=$4
ALLOWED_IDS="${@:5}"
[ -n "$DOMAIN" ] || read -r -p "domain for the server: " DOMAIN
[ -n "$TOKEN" ] || read -r -p "telegram token for the server: " TOKEN
[ -n "$ADMIN_PASS" ] || read -r -p "admin password" ADMIN_PASS
[ -n "$HA_TOKEN" ] || read -r -p "token on which data is recieved: " HA_TOKEN
[ -n "$ALLOWED_IDS" ] || read -r -p "telegram ids that can access the bot: " ALLOWED_IDS

# add user if not yet present
sudo adduser ha

EXEC=/home/ha/homeAutomation
while true
do
	read -r -p "please move the executable to $EXEC [press enter to continue]" input
	[[ -f $EXEC ]] && break
	echo "could not find file"
done

sudo chown -R ha:ha /home/ha/
sudo chmod +x /home/ha/homeAutomation

# setup service
cp ../config/ha.service /etc/systemd/system/ha.service

# set templated vars
sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/systemd/system/ha.service
sed -i "s/<TOKEN>/$TOKEN/g" /etc/systemd/system/ha.service
sed -i "s/<ADMIN_PASS>/$ADMIN_PASS/g" /etc/systemd/system/ha.service
sed -i "s/<HA_TOKEN>/$HA_TOKEN/g" /etc/systemd/system/ha.service
sed -i "s/<ALLOWED_IDS>/$ALLOWED_IDS/g" /etc/systemd/system/ha.service

sudo systemctl enable ha
sudo systemctl start ha
