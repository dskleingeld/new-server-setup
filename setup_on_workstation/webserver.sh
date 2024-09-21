#!/usr/bin/env bash

SERVER="sgc"

dir=`mktemp -d`
# todo: depends on CV which is not a git repo but must 
# be availible at: ~Documents/Jobs/CV
git clone https://github.com/dvdsk/site $dir

cd $dir
make deploy
cd -
