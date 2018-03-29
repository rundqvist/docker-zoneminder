# Docker Zoneminder
All-in-one Zoneminder image built on Alpine Linux and Php7.

## Components
* Alpine Linux
* Zoneminder
* MariaDB
* Lighttpd
* Php7

## Run (from docker hub)
```
docker run \
-d \
--shm-size=4096m \
--privileged \
-p 8080:80 \
--name zoneminder \
-v /path/to/data:/data \
-v /path/to/images:/images \
-v /path/to/events:/events \
-e 'TZ=Europe/Stockholm' \
rundqvist/zoneminder
```

## Use
Login to http://your-ip:8080/zm
Api located at http://your-ip:8080/zm/api
