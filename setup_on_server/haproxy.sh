#!/usr/bin/env bash
set -e

#
# HAproxy and certbot install and configure script
# intended to be ran as a user with sudo rights from the
# setup folder
#

DOMAIN=$1 # optional argument: domain
STATS_PASSW=$2 # optional argument: statistic page password
[ -n "$DOMAIN" ] || read -r -p "enter domain on which to deploy: " DOMAIN
[ -n "$STATS_PASSW" ] || read -r -p "enter stats page admin password: " STATS_PASSW

# install haproxy and certbot
sudo apt-get install -y haproxy certbot -

# setup haproxy user if it does not exist yet
id -u haproxy&>/dev/null || sudo useradd --no-create-home --shell /sbin/nologin haproxy

# move config into place, set the correct domain and set root owned
for file in haproxy.cfg hosts.map; do
	sudo cp ../config/$file /etc/haproxy/
	sudo sed -i "s/<DOMAIN>/$DOMAIN/g" /etc/haproxy/$file  # set domain
	sudo sed -i "s/<STATS_PASSW>/$STATS_PASSW/g" /etc/haproxy/$file  # set domain
	sudo chown root:root /etc/haproxy/$file  # no reason for mortals to touch this
done

# install systemd service and enable it
SYSTEMD_DIR=/etc/systemd/system/
sudo cp ../config/haproxy.service $SYSTEMD_DIR
sudo systemctl enable haproxy

# ask user if they want to run initial certbot run
if [[ ! -f /etc/ssl/certs/$DOMAIN.pem ]]; then
	echo "ERROR: need to set up certs (certs.sh) before haproxy can run"
	echo "exiting"
	exit
fi

sudo systemctl restart haproxy
