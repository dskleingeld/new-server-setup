#!/usr/bin/env bash
set -e

#
# HAproxy and certbot install and configure script
# intended to be ran as a user with sudo rights from the
# setup folder
#

# install haproxy and certbot
sudo apt-get install -y haproxy certbot -

# setup haproxy user
sudo usermod -s /sbin/nologin haproxy

# move config into place
sudo cp ../config/haproxy.cfg /etc/haproxy/
sudo chown root:root /etc/haproxy/haproxy.cfg # no reason for mortals to access this

# install systemd service and enable it
SYSTEMD_DIR=/etc/systemd/system/
sudo cp ../config/haproxy.service $SYSTEMD_DIR
sudo systemctl enable haproxy
sudo systemctl start haproxy



# setup timer to run certificates update script twice a day
SCRIPT_DIR=/usr/bin/
sudo cp ../bin/request_certs.sh $SCRIPT_DIR
sudo chown root:root /usr/bin/request_certs.sh # no reason for mortals to access this

sudo cp ../config/renew_certs.service $SYSTEMD_DIR
sudo cp ../config/renew_certs.timer $SYSTEMD_DIR
sudo systemctl enable renew_certs
sudo systemctl start renew_certs



# ask user if they want to run initial certbot run
read -r -p "request fresh certificate? [y/N] " input
if [[ $input == "y" ]]; then
	echo "requesting fresh certificate"
	sudo .${SCRIPT_DIR}renew_certs.sh --renew
fi
