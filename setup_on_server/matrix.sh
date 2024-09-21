#!/usr/bin/env bash
set -e 

# templated vars
DOMAIN=$1
[ -n "$DOMAIN" ] || read -r -p "enter domain: " DOMAIN
PORT=$2
[ -n "$PORT" ] || read -r -p "enter port: " PORT
USER=$3
[ -n "$USER" ] || read -r -p "enter user to run server on: " USER

# add user with home dir if not yet present
id -u $USER&>/dev/null || sudo useradd -m $USER

EXEC=/home/$USER/conduit
URL=https://gitlab.com/api/v4/projects/famedly%2Fconduit/jobs/artifacts/master/raw/aarch64-unknown-linux-musl?job=artifacts
sudo systemctl stop $USER
sudo wget -O $EXEC $URL
sudo chmod +x $EXEC
sudo chown $USER:$USER $EXEC


# set up conduit (server) config
sudo cp ../config/conduit.toml /home/$USER/
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /home/$USER/conduit.toml
sudo sed -i "s/<PORT>/$PORT/g" /home/$USER/conduit.toml
sudo chown $USER:$USER /home/$USER/conduit.toml

# set up service config
sudo cp ../config/matrix.service /etc/systemd/system/$USER.service
sudo sed -i "s/<USER>/$USER/g" /etc/systemd/system/$USER.service

# enable start service
sudo systemctl enable $USER
sudo systemctl restart $USER
