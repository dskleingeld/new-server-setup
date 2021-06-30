#!/usr/bin/env bash
set -e

# updates ssl certificate and combines output into a single key understandable by HAproxy
# must be run as root

DOMAIN="<DOMAIN>"
PORT=34320  # local port to which 80 is forwarded
EMAIL="admin@$DOMAIN"
SOURCE="/etc/letsencrypt/live/$DOMAIN"
TARGET_DIR="/etc/ssl/certs"
CERT="$DOMAIN.pem"

secs_since_change() {
	curtime=$(date +%s)
	filetime=$(stat $0 -C %Y)
	timediff=$(expr $curtime - $filetime)
	echo $timediff
}


if [[ $1 == "--renew" ]]; then
	certbot renew --http-01-port=$PORT
elif [[ $1 == "--request" ]]; then
	certbot certonly --standalone -d $DOMAIN \
		--non-interactive --agree-tos --email $EMAIL \
		--http-01-port=$PORT
else
	printf "\033[0;31mERROR call with --renew or --request\n"
	exit -1
fi


# get latest cert files
fullchain=$(ls $SOURCE/fullchain*.pem | sort | head -n 1)
privkey=$(ls $SOURCE/privkey*.pem | sort | head -n 1)

# exit with error if no chain found
if [[ -z "$fullchain" ]]; then 
	printf "\033[0;31mNo cert files exist in $SOURCE\n"
	exit -1
fi

# exit if cert not renewed
if [[ $(secs_since_change $fullchain) -gt 5 ]]; then
	printf "\033[0;33mCert not renewed, exiting\n"
	exit 0
fi

# concat so haproxy can load it and move to target dir
cat $fullchain $privkey > $TARGET_DIR/$CERT

# restrict access to certs to root only
chown root:root $TARGET_DIR/$CERT 
chmod 700 $TARGET_DIR/$CERT

# Reload HAProxy if renew
echo "certificates updated"
[[ $1 == "--renew" ]] && systemctl reload haproxy

