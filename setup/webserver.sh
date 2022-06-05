#!/usr/bin/env bash
set -e

# add user if not yet present
id -u webserver&>/dev/null || sudo useradd -m webserver

EXEC=/home/webserver/webserver
PUBLIC=/home/webserver/files/public

TEXT="please move the webserver executable to: $EXEC,
the assets for the public site to $PUBLIC and
private dashboard (TODO)"
while true
do
	read -r -p "$TEXT" input
	if ! sudo test -x $EXEC; then echo "could not find webserver executable"; continue; fi
	if ! sudo test -d $PUBLIC; then echo "could not find static files for public site"; continue; fi
	break
done

sudo chown -R webserver:webserver /home/webserver/
sudo chmod +x $EXEC

# setup service
sudo cp ../config/webserver.service /etc/systemd/system/webserver.service

sudo systemctl enable webserver
sudo systemctl restart webserver
