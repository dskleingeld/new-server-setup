#!/usr/bin/env bash

SERVER="sgc"

dir=`mktemp -d`
git clone https://github.com/dvdsk/sensor_central $dir

cd $dir

cross build --target=aarch64-unknown-linux-musl --release
rsync -vh --progress \
	target/aarch64-unknown-linux-musl/release/sensor_central \
	$SERVER:/tmp/

cmds="
sudo mv /tmp/sensor_central /home/ha/
sudo chown ha:ha /home/ha/sensor_central
sudo systemctl restart sens.service
"

ssh -t $SERVER "$cmds"
cd -
