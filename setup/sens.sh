#!/usr/bin/env bash
set -e

EXEC=/home/ha/sensor_central
while true
do
	sudo test -f $EXEC && break
	read -r -p "please move the executable to $EXEC [press enter to continue]" input
done

sudo chown -R ha:ha /home/ha/
sudo chmod +x $EXEC

# setup service
sudo cp ../config/sens.service /etc/systemd/system/sens.service

DATA_KEY=$1
HA_KEY=$2
[ -n "$DATA_KEY" ] || read -r -p "dataserver key: " DATA_KEY
[ -n "$HA_KEY" ] || read -r -p "home automation key: " HA_KEY

# set templated vars
sudo sed -i "s/<DATA_KEY>/$DATA_KEY/g" /etc/systemd/system/sens.service
sudo sed -i "s/<HA_KEY>/$HA_KEY/g" /etc/systemd/system/sens.service

sudo systemctl enable sens
sudo systemctl start sens
