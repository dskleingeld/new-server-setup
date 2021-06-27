# Home server setup:

Personal home server setup hosting:
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

## Forwarding and TLS
HAproxy is used to
- forwarding https traffic to backends based on url
- handle tls termination (port 443 and 8443)

HAproxy is started by systemd as root, binds to privelledged ports and then runs as that user *haproxy*. I use systemd to sandbox HAproxy as much as possible. I use certbot to request and renew the certificate. Certbot is ran twice a day using systemd timers.

### local ports
Ports should be assigned between 1024 and 49151. I use 34320-34325
 - matrix homeserver TODO
 - home automation (ha) 34320
 - data splitter (datasplitter) 34321
 - data server (data) 34322
 - data server dev (data\_dev) 34323

### install
Simply clone this repo and run setup/haproxy.sh

## Matrix
TODO

## Home Automation
From sensordata, button presses, wakeup time, playing audio and telegram bot input: manages wakeup "alarm", lamps and music. [source](https://github.com/dskleingeld/HomeAutomation).

Recieves: 
on domain.tld:433/ha\_key: TODO change to ha.domain.tld/ha\_key
- sensordata (including button pushes) from microservice [sensor central](https://github.com/dskleingeld/sensor_central) 
on domain.tld:433/bot\_token: TODO change to ha.domain.tld/bot\_token
- telegram bot messages via webhook 
on domain.tld:433/alarm/..: TODO change to ha.domain.tld/wakeup/..
- wakeup time from [alarm app](https://github.com/dskleingeld/alarm)
on domain.tld:433/commands/..  TODO change to ha.domain.tld/api/..
- http api to perform an action or change state

### install 
Run setup/ha.sh

## Home Data Collection
Collects and inspect data from various sensors. Provides notifications at threshold values, interface using telegram bot and site. [source](https://github.com/dskleingeld/dataserver)

Recieves: TODO change all these to data.domain.tld/..
on domain.tld:88/post\_..:
- sensor data from microservice [sensor central](https://github.com/dskleingeld/sensor_central) 
- sensor data from remote wifi sensor
on domain.tld:88/..:
- site, websocket data, static files
on domain.tld:88/bot\_token:
- telegram bot

I also run a development version of this on dev.data.domain.tld/.. incoming data is split between both instances using [data splitter](https://github.com/dskleingeld/datasplitter). It recieves domain.tld:88/post\_.. and forwards it to both instances.

### install 
Run setup/data.sh
