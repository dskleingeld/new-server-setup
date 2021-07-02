#!/usr/bin/env bash
set -e

# should always be ran after matrix install
#

source util.sh

ensure_docker
sudo usermod -aG docker matrix

DIR=/home/matrix/bridges/telegram
sudo mkdir -p $DIR 
sudo chown -R matrix:matrix $DIR

# setup config 
DOMAIN=$1
[ -n "$DOMAIN" ] || read -r -p "domain for the server: " DOMAIN
sudo cp ../../config/matrix_bridges/bridge_telegram.yaml \
	$DIR/config.yaml
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" $DIR/config.yaml
sudo chown matrix:matrix $DIR/config.yaml

# generate appservice registration
IMG=dock.mau.dev/tulir/mautrix-telegram:latest
sudo -u matrix docker pull $IMG

# generate registration if not present
if sudo test -f $DIR/registration.yaml; then
	sudo -u matrix docker run --mount src=$DIR,target=/data,type=bind $IMG
	echo "registration file generated, please copy it to you homeserver"
fi

# setup service
sudo cp ../../config/matrix_bridges/bridge_telegram.service \
	/etc/systemd/system/matrix_bridge_telegram.service
sudo sed -i "s+<IMG>+$IMG+g" /etc/systemd/system/matrix_bridge_telegram.service

sudo systemctl enable matrix_bridge_telegram
sudo systemctl restart matrix_bridge_telegram
