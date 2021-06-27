#!/usr/bin/env bash
set -e

# This script only sets up the user for the data and data splitter service
# it does not compile the executable nor move them in place

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
	sudo systemctl enable $service
	sudo systemctl start $service
done
