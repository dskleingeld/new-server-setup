#!/usr/bin/env bash
set -e

# This script only sets up the user for the data and data splitter service
# it does not compile the executable nor move them in place

# add user with home dir if not yet present
id -u data&>/dev/null || sudo useradd -m data

SPLITTER=/home/data/datasplitter
SERVER=/home/data/dataserver
DEV_SERVER="/home/$USER/dataserver_dev/dataserver"
mkdir -p $(dirname $DEV_SERVER)

TEXT=$(echo "please move: 
	the splitter executable to $SPLITTER 
	the server executable to $SERVER,
	the dev server executable to $DEV_SERVER,
	[press enter to continue]")

while true
do
	read -r -p "$TEXT" input
	if ! sudo test -x $SPLITTER; then echo "could not find splitter"; continue; fi
	if ! sudo test -x $SERVER; then echo "could not find server"; continue; fi
	if ! sudo test -x $DEV_SERVER; then echo "could not find dev server"; continue; fi
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

DOMAIN=$1
TOKEN=$2
DEV_DOMAIN=$3
DEV_TOKEN=$4
[ -n "$DOMAIN" ] || read -r -p "domain for the stable server: " DOMAIN
[ -n "$TOKEN" ] || read -r -p "telegram token for the stable server: " TOKEN
[ -n "$DEV_DOMAIN" ] || read -r -p "domain for the dev server: " DEV_DOMAIN
[ -n "$DEV_TOKEN" ] || read -r -p "telegram token for the dev server: " DEV_TOKEN

# set env variables
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/systemd/system/data.service
sudo sed -i "s/<TOKEN>/$TOKEN/g" /etc/systemd/system/data.service
sudo sed -i "s/<DOMAIN>/$DEV_DOMAIN/g" /etc/systemd/system/data_dev.service
sudo sed -i "s/<TOKEN>/$DEV_TOKEN/g" /etc/systemd/system/data_dev.service
sudo sed -i "s/<USER>/$USER/g" /etc/systemd/system/data_dev.service

for service in data data_dev datasplitter; do
	sudo systemctl enable $service
	sudo systemctl restart $service
done
