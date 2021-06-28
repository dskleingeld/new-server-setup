#!/usr/bin/env bash
set -e

# updates ssl certificate and combines output into a single key understandable by HAproxy

DOMAIN="<DOMAIN>"
PORT=34320  # local port to which 80 is forwarded
EMAIL="admin@$DOMAIN"
TARGET_DIR="/etc/ssl/certs"
CERT="$DOMAIN.pem"

if [[ $1 == "--renew" ]]; then
	certbot renew --http-01-port=$PORT || exit 0
elif [[ $1 == "--request" ]]; then
	certbot certonly --standalone -d $DOMAIN \
		--non-interactive --agree-tos --email $EMAIL \
		--http-01-port=$PORT
else
	echo "ERROR call with --renew or --request"
	exit -1
fi

# Concatenate latest cert files and move to target dir
SOURCE=/etc/letsencrypt/live/$DOMAIN
fullchain=$(ls $SOURCE/fullchain*.pem | sort | head -n 1)
privkey=$(ls $SOURCE/privkey*.pem | sort | head -n 1)
cat $fullchain $privkey > $TARGET_DIR/$CERT

# restrict access to certs to root only
chown root:root $TARGET_DIR/$CERT 
chmod 700 $TARGET_DIR/$CERT

# Reload HAProxy if renew
echo "certificates updated, reloading haproxy"
[[ $1 == "--renew" ]] && systemctl reload haproxy

