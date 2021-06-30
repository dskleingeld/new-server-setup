#!/usr/bin/env bash
set -e

#
# will rename the user/group that calls it to a new name
#

sudo timedatectl set-timezone Europe/Amsterdam

exit -1  # not yet done

OLD_USER=$USER
NEW_USER=david

sudo su
sudo adduser temp
sudo usermod -aG sudo temp

# need to login again with temp user
usermod -l $NEW_USER $OLD_USER
groupmod --new_name $NEW_USER $OLD_USER
mv /home/$OLD_USER /home/$NEW_USER

sudo userdel temp
