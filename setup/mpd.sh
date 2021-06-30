#!/usr/bin/env bash
set -e

sudo apt install mpd

#set up config and add mpd user
sudo cp ../config/mpd.conf /etc/
id -u mpd&>/dev/null || sudo useradd mpd

# add shared music dir with access for the group music 
sudo mkdir -p /srv/music
getent group music&>/dev/null || sudo groupadd music  # add group only if it did not exist
sudo chgrp -R music /srv/music
sudo chmod -R 2775 /srv/music

# add mpd, ha (home automation) and current user to music
sudo usermod -aG music mpd
sudo usermod -aG music ha
sudo usermod -aG music $USER

echo "done, music should be placed in /srv/music"
