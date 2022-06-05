#!/usr/bin/env bash
set -e

# should always be ran after matrix install
#

source util.sh

ensure_docker
sudo usermod -aG docker matrix

DIR=/home/matrix/bridges/signal
sudo mkdir -p $DIR
sudo mkdir -p $DIR/data 
sudo chown -R matrix:matrix $DIR
sudo chown -R matrix:matrix $DIR/data

# setup config 
DOMAIN=$1
[ -n "$DOMAIN" ] || read -r -p "domain for the server: " DOMAIN
PASSW="$RANDOM$RANDOM$RANDOM"

sudo cp ../../config/matrix_bridges/bridge_signal.yaml \
	$DIR/data/config.yaml
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" $DIR/data/config.yaml
sudo sed -i "s/<PASSW>/$PASSW/g" $DIR/data/config.yaml
sudo chown matrix:matrix $DIR/data/config.yaml

sudo cp ../../config/matrix_bridges/signal-docker-compose.yaml \
	$DIR/docker-compose.yaml
sudo sed -i "s/<PASSW>/$PASSW/g" $DIR/docker-compose.yaml
sudo chown matrix:matrix $DIR/docker-compose.yaml

sudo su matrix <<- EOF
	cd /home/matrix/bridges/signal
	docker-compose up -d signald

	if ! test -f $DIR/data/registration.yaml; then
		docker-compose up mautrix-signal
		docker-compose stop mautrix-signal
		echo "registration file generated, please copy it to you homeserver"
		cat "$DIR/data/registration.yaml"
	fi
EOF

# generate registration if not present

# # # copy registration data into config
# # as_token=$(sudo head -2 $DIR/registration.yaml | tail -1 | cut -d " " -f 2)
# # hs_token=$(sudo head -3 $DIR/registration.yaml | tail -1 | cut -d " " -f 2)
# # sudo sed -i "s/<AS_TOKEN>/$as_token/g" $DIR/config.yaml
# # sudo sed -i "s/<HS_TOKEN>/$hs_token/g" $DIR/config.yaml

# # setup service
# sudo cp ../../config/matrix_bridges/bridge_signal.service \
# 	/etc/systemd/system/matrix_bridge_signal.service
# sudo sed -i "s+<IMG>+$IMG+g" /etc/systemd/system/matrix_bridge_signal.service

# sudo systemctl enable matrix_bridge_signal
# sudo systemctl restart matrix_bridge_signal
