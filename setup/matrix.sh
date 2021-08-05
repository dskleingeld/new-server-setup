#!/usr/bin/env bash
set -e 

# add user with home dir if not yet present
id -u matrix&>/dev/null || sudo useradd -m matrix

# TEXT=$(echo "please move: 
# 	the matrix homeserver executable to $EXEC,
# 	[press enter to continue]")

# while true
# do
# 	read -r -p "$TEXT" input
# 	if ! sudo test -x $EXEC; then echo "conduit server exec not found"; continue; fi
# 	break
# done

EXEC=/home/matrix/conduit
URL=https://conduit.rs/master/armv8/conduit-bin
if ! sudo test -x $EXEC; then 
	sudo wget -O $EXEC $URL
	sudo chmod +x $EXEC
	sudo chown matrix:matrix $EXEC
fi

# set up config
sudo cp ../config/conduit.toml /home/matrix/

# set templated vars
DOMAIN=$1
[ -n "$DOMAIN" ] || read -r -p "enter domain: " DOMAIN
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /home/matrix/conduit.toml
sudo chown matrix:matrix /home/matrix/conduit.toml

# setup and start service
sudo cp ../config/matrix.service /etc/systemd/system/
sudo systemctl enable matrix
sudo systemctl restart matrix
