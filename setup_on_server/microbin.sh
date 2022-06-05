#!/usr/bin/env bash
set -e

# This script only sets up the user for the home automation service
# it does not compile the executable
USER=microbin

# add user if not yet present
id -u $USER&>/dev/null || sudo useradd -m $USER

EXEC=/home/$USER/microbin
while true
do
	sudo test -f $EXEC && break
	read -r -p "please move the executable to $EXEC [press enter to continue]" input
done

sudo chown -R $USER:$USER /home/$USER/
sudo chmod +x /home/$USER/microbin

# setup service
sudo cp ../config/microbin.service /etc/systemd/system/microbin.service

USERNAME=$1
PASSWORD=$2
[ -n "$USERNAME" ] || read -r -p "username for the microbin page: " USERNAME
[ -n "$PASSWORD" ] || read -r -p "password for the microbin page: " PASSWORD

# set templated vars
sudo sed -i "s/<USERNAME>/$USERNAME/g" /etc/systemd/system/microbin.service
sudo sed -i "s/<PASSWORD>/$PASSWORD/g" /etc/systemd/system/microbin.service

sudo systemctl enable microbin
sudo systemctl restart microbin
