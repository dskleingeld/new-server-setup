#!/usr/bin/env bash
set -e

DOMAIN="davidsk.dev"
DIR="/etc/ssl/certs"
CERT="test"

if [[ $1 == "--renew" ]]; then
	certbot renew --force-renewal --tls-sni-01-port=8888
elif [[ $1 == "--request" ]]; then
	certbot certonly --standalone -d $DOMAIN \
		--non-interactive --agree-tos --email admin@example.com \
		--http-01-port=8888
else
	echo "ERROR call with --renew or --request"
	exit -1
fi


# Concatenate new cert files, with less output (avoiding the use tee and its output to stdout)
cat $DIR/$CERT/fullchain.pem $DIR/$CERT/privkey.pem > $DIR/$CERT

# Reload  HAProxy
systemctl reload haproxy
