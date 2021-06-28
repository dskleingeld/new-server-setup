#!/usr/bin/env bash
set -e

#
# HAproxy and certbot install and configure script
# intended to be ran as a user with sudo rights from the
# setup folder
#

DOMAIN=$1 # optional argument: domain
[ -n "$DOMAIN" ] || read -r -p "enter domain on which to deploy: " DOMAIN

# install haproxy and certbot
sudo apt-get install -y haproxy certbot -

# setup haproxy user
sudo usermod -s /sbin/nologin haproxy

# move config into place, set the correct domain and set root owned
for file in haproxy.cfg hosts.map; do
	sudo cp ../config/$file /etc/haproxy/
	sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/haproxy/$file  # set domain
	sudo chown root:root /etc/haproxy/$file  # no reason for mortals to touch this
done

# install systemd service and enable it
SYSTEMD_DIR=/etc/systemd/system/
sudo cp ../config/haproxy.service $SYSTEMD_DIR
sudo systemctl enable haproxy


# setup timer to run certificates update script twice a day
sudo cp ../bin/request_certs.sh /usr/bin/
sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /usr/bin/request_certs.sh  # set domain
sudo chown root:root /usr/bin/request_certs.sh  # no reason for mortals to access this

sudo cp ../config/renew_certs.service $SYSTEMD_DIR
sudo cp ../config/renew_certs.timer $SYSTEMD_DIR
sudo systemctl enable renew_certs


# ask user if they want to run initial certbot run
if [[ ! -f /etc/ssl/certs/$DOMAIN.pem ]]; then
	echo "need to request fresh certificate"

	read -r -p "request fresh certificate? [y/N] " input
	if [[ $input == "y" ]]; then
		echo "requesting"
		sudo /usr/bin/request_certs.sh --request
	fi
fi

sudo systemctl start haproxy
sudo systemctl start renew_certs
