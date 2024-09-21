#!/usr/bin/env bash

set -e

SERVER="sgc"

dir=`mktemp -d`
git clone https://github.com/dvdsk/HomeAutomation $dir

cd $dir

cross build --target=aarch64-unknown-linux-musl --release
rsync -vh --progress \
	target/aarch64-unknown-linux-musl/release/HomeAutomation \
	$SERVER:/tmp/

cmds="
sudo mv /tmp/HomeAutomation /home/ha/
sudo chown ha:ha /home/ha/HomeAutomation
sudo systemctl restart ha.service
"

ssh -t $SERVER "$cmds"
cd -
