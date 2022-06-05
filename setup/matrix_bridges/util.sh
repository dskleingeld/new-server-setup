#!/usr/bin/env bash
set -e

exists() {
	command -v $1 &> /dev/null
	return $?
}

ensure_docker() {
	if exists docker; then 
		return
	fi

	if exists docker-compose; then
		return
	fi

	sudo apt-get update
	sudo apt-get install --assume-yes \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release

	# add docker key
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
		| sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

	# add add docker source.list for current ubuntu release (lsb_release -cs)
	echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# actually install docker
	sudo apt-get update
	sudo apt-get install --assume-yes docker-ce docker-ce-cli containerd.io docker-compose

	# set up docker group
	getent group docker&>/dev/null || sudo groupadd docker  # add group only if it did not exist
}
