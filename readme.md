Home linux based server hosting:

- haproxy for tls and forwarding
- matrix homeserver
	- telegram matrix bridge
	- discord matrix bridge
<!-- - private site -->
- home automation backend
- home data backend
	- data splitter
	- data server 
	- data server dev

# Forwarding and TLS
HAproxy is used to
- forwarding https traffic to backends based on url
- handle tls termination (port 443 and 8443)

HAproxy is started by systemd as root, binds to privelledged ports and then runs as that user *haproxy*. I use systemd to sandbox HAproxy as much as possible. I use certbot to request and renew the certificate. Certbot is ran twice a day using systemd timers.

## install
Simply clone this repo and run setup/haproxy.sh

# Matrix

# Home Automation

# Home Data
<!-- ## setup 

Install certbot and haproxy 

### tls certs
(First time setup only) request a new certificate using certbot, haproxy needs to be configured already, use `request_cert.sh`. Set up 
 -->
