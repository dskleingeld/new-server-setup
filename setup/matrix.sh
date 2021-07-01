#!/usr/bin/env bash

# add user with home dir if not yet present
id -u matrix&>/dev/null || sudo useradd -m matrix

# EXEC=/home/matrix/conduit
# TEXT=$(echo "please move: 
# 	the matrix homeserver executable to $EXEC,
# 	[press enter to continue]")

# while true
# do
# 	read -r -p "$TEXT" input
# 	if ! sudo test -x $EXEC; then echo "conduit server exec not found"; continue; fi
# 	break
# done

URL=https://conduit.rs/master/armv8/conduit-bin
if ! sudo test -x $EXEC; then 
	sudo wget -O $EXEC $URL
	sudo chmod +x $EXEC
	sudo chown matrix:matrix $EXEC
fi

sudo chown -R data:data /home/data/
sudo chmod +x $SERVER

sudo cp ../config/matrix.service /etc/systemd/system/
sudo cp ../config/conduit.toml /home/matrix/

# set templated vars
DOMAIN=$1
[ -n "$DOMAIN" ] || read -r -p "name for matrix home server: " DOMAIN
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/systemd/system/matrix.service

# setup and start service
sudo chown matrix:matrix /home/matrix/conduit.toml

sudo systemctl enable matrix
sudo systemctl restart matrix
