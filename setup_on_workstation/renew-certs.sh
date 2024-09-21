#!/usr/bin/env bash

SERVER="sgc"

DOMAIN=$1 # optional argument: domain
[ -n "$DOMAIN" ] || read -r -p "enter domain on which to deploy: " DOMAIN
PORT=34320

dir=`mktemp -d`
git clone https://github.com/dvdsk/renew-certs $dir

cd $dir
./crosscompile.sh

rsync -vh --progress \
	target/aarch64-unknown-linux-musl/release/renew-certs \
	$SERVER:/tmp/

cmds="
sudo mv /tmp/renew-certs /home/david/
sudo chown david:david /home/david/renew-certs
"
# todo move to script file to run on server
# echo \"creating fresh certs\"
# sudo renew-certs run \
# 	--path /etc/ssl/certs/davidsk.dev \
# 	--port 80 \
# 	--domains davidsk.dev 
# 	--domains www.davidsk.dev 
# 	--domains ha.davidsk.dev 
# 	--domains data.davidsk.dev 
# 	--domains dev_data.davidsk.dev 
# echo \"schedualing run behind load balancer\"
# sudo renew-certs run \
# 	--path /etc/ssl/certs/davidsk.dev \
# 	--port 80 \
# 	--domains davidsk.dev 
# 	--domains www.davidsk.dev 
# 	--domains ha.davidsk.dev 
# 	--domains data.davidsk.dev 
# 	--domains dev_data.davidsk.dev 
# sudo renew-certs install --path /etc/ssl/certs/davidsk.dev --port 34320 --domains www.davidsk.dev 

ssh -t $SERVER "$cmds"
cd -
