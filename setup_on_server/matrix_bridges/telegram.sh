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
while ! sudo test -f $DIR/registration.yaml; do
	sudo -u matrix docker run --mount src=$DIR,target=/data,type=bind $IMG
	echo "registration file generated, please copy it to you homeserver"
	sudo cat "$DIR/registration.yaml"
done

# # copy registration data into config
# as_token=$(sudo head -2 $DIR/registration.yaml | tail -1 | cut -d " " -f 2)
# hs_token=$(sudo head -3 $DIR/registration.yaml | tail -1 | cut -d " " -f 2)
# sudo sed -i "s/<AS_TOKEN>/$as_token/g" $DIR/config.yaml
# sudo sed -i "s/<HS_TOKEN>/$hs_token/g" $DIR/config.yaml

# setup service
sudo cp ../../config/matrix_bridges/bridge_telegram.service \
	/etc/systemd/system/matrix_bridge_telegram.service
sudo sed -i "s+<IMG>+$IMG+g" /etc/systemd/system/matrix_bridge_telegram.service

sudo systemctl enable matrix_bridge_telegram
sudo systemctl restart matrix_bridge_telegram
