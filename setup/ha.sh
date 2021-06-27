#!/usr/bin/env bash
set -e

# This script only sets up the user for the home automation service
# it does not compile the executable

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
sudo systemctl enable ha
sudo systemctl start ha
