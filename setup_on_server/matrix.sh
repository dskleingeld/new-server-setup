#!/usr/bin/env bash
set -e 


function setup_a_server {
	DOMAIN=${1:?Must pass DOMAIN as first argument}
	PORT=${2:?Must pass PORT as second argument}
	USER=${3:?Must pass USER as third argument}

	# add user with home dir if not yet present
	id -u $USER&>/dev/null || sudo useradd -m $USER

	EXEC=/home/$USER/conduit
	URL=https://gitlab.com/api/v4/projects/famedly%2Fconduit/jobs/artifacts/master/raw/aarch64-unknown-linux-musl?job=artifacts
	sudo systemctl stop $USER | true
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
}

setup_a_server davidsk.dev 34321 matrix_david
setup_a_server evavh.net 34323 matrix_eva
