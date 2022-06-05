#!/usr/bin/env bash
set -e 

# add user with home dir if not yet present
id -u matrix&>/dev/null || sudo useradd -m matrix

EXEC=/home/matrix/conduit
URL=https://gitlab.com/famedly/conduit/-/jobs/artifacts/master/raw/conduit-aarch64-unknown-linux-musl?job=build:release:cargo:aarch64-unknown-linux-musl
sudo systemctl stop matrix
sudo wget -O $EXEC $URL
sudo chmod +x $EXEC
sudo chown matrix:matrix $EXEC

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
