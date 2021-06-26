#!/usr/bin/env bash
set e

# install haproxy and certbot
sudo apt-get install -y haproxy certbot -

# setup haproxy user
usermod -s /sbin/nologin haproxy

# move config into place
sudo cp ../setup/haproxy.cfg /etc/haproxy/
sudo chown root:root /etc/haproxy/haproxy.cfg # no reason for mortals to access this

# install systemd service and enable it
SYSTEMD_DIR=/etc/systemd/system/
sudo cp ../setup/haproxy.service $SYSTEMD_DIR
sudo systemctl enable haproxy
sudo systemctl start haproxy



# setup timer to run certificates update script twice a day
SCRIPT_DIR=/usr/bin/
sudo cp ../bin/renew_certs.sh $SCRIPT_DIR
sudo chown root:root /usr/bin/renew_certs.sh # no reason for mortals to access this

sudo cp ../setup/renew_certs.service $SYSTEMD_DIR
sudo cp ../setup/renew_certs.timer $SYSTEMD_DIR
sudo systemctl enable renew_certs
sudo systemctl start renew_certs



# ask user if they want to run initial certbot run
read -r -p "request fresh certificate? [y/N] " input
if [[ $input == "y" ]]; then
	echo "requesting fresh certificate"
	sudo .${SCRIPT_DIR}renew_certs.sh --renew
fi
