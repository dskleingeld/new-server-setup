#!/usr/bin/env bash
set -e

# updates ssl certificate and combines output into a single key understandable by HAproxy
# must be run as root with arguments --renew or --request and second argument --production
# to get valid requests (by default run agains letsencrypt staging env)

DOMAIN="davidsk.dev"
# can not use a catch all because then we need dns level verification which is dep on porvider
SUBDOMAINS=(data dev.data ha paste www) 
PORT=34320  # local port to which 80 is forwarded
EMAIL="admin@$DOMAIN"
SOURCE="/etc/letsencrypt/live/$DOMAIN"
TARGET_DIR="/etc/ssl/certs"
CERT="$DOMAIN.pem"

# build comma seperated list [@]/%/text adds a suffix
# to each element in the SUBDOMAINS array
domains="$DOMAIN ${SUBDOMAINS[@]/%/.$DOMAIN}"
domains=$(echo $domains | tr " " ,)
echo domains: $domains

secs_since_change() {
	curtime=$(date +%s)
	filetime=$(stat $0 -c %Y)  # last modification, seconds since Epoch 
	timediff=$(expr $curtime - $filetime)
	echo $timediff
}

STAGING="--staging"
[[ $2 == "--production" ]] && STAGING=""
if [[ $1 == "--renew" ]]; then
	certbot renew $STAGING --http-01-port=$PORT
elif [[ $1 == "--request" ]]; then
	certbot certonly $STAGING --standalone -d $domains \
		--non-interactive --agree-tos --email $EMAIL \
		--http-01-port=$PORT --expand
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
if [[ $(secs_since_change $fullchain) -gt 30 ]]; then
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
systemctl reload haproxy
