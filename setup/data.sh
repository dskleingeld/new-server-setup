#!/usr/bin/env bash
set -e

# This script only sets up the user for the data and data splitter service
# it does not compile the executable nor move them in place

DOMAIN=$1
TOKEN=$2
DEV_DOMAIN=$3
DEV_TOKEN=$4
[ -z "$DOMAIN" ] || read -r -p "domain for the stable server: " DOMAIN
[ -z "$TOKEN" ] || read -r -p "telegram token for the stable server: " TOKEN
[ -z "$DEV_DOMAIN" ] || read -r -p "domain for the dev server: " DEV_DOMAIN
[ -z "$DEV_TOKEN" ] || read -r -p "telegram on which to deploy: " DEV_TOKEN

# add user if not yet present
sudo adduser data

SERVER=/home/data/dataserver
DEV_SERVER=/home/pi/dataserver_dev/dataserver
SPLITTER=/home/data/datasplitter
text="please move: 
	the server executable to $SERVER,
	the dev server executable to $DEV_SERVER,
	the splitter executable to $SPLITTER 
	[press enter to continue]" 

while true
do
	read -r -p $text input
	[[ -f $SERVER ]] && echo "could not find server"; continue
	[[ -f $DEV_SERVER ]] && echo "could not find dev server"; continue
	[[ -f $SPLITTER ]] && echo "could not find splitter"; continue
	break
done

sudo chown -R data:data /home/data/
sudo chmod +x $SERVER
sudo chmod +x $DEV_SERVER
sudo chmod +x $SPLITTER

# setup and start service
for service in data data_dev datasplitter; do
	sudo cp ../config/$service.service /etc/systemd/system/$service.service
done

# set env variables
sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/systemd/system/data.service
sed -i "s/<TOKEN>/$TOKEN/g" /etc/systemd/system/data.service
sed -i "s/<DOMAIN>/$DEV_DOMAIN/g" /etc/systemd/system/dev_data.service
sed -i "s/<TOKEN>/$DEV_TOKEN/g" /etc/systemd/system/dev_data.service

for service in data data_dev datasplitter; do
	sudo systemctl enable $service
	sudo systemctl start $service
done
