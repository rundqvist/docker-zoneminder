# Docker Zoneminder
All-in-one Zoneminder image built on Alpine Linux and Php7.

## Components
* Alpine Linux
* Zoneminder
* MariaDB
* Lighttpd
* Php7

## Configuration
| Variable | Usage |
|----------|-------|
| UID | UID of user with access to /events and /images folder. Optional, but can cause permission issues if omitted. |
| GID | GID of user with access to /events and /images folder. Optional, but can cause permission issues if omitted. |
| TZ | Your time zone. Default is Europe/Stockholm. |

## Run (from docker hub)
```
$ docker run \
    -d \
    --shm-size=4096m \
    --privileged \
    -p 8080:80 \
    --name zoneminder \
    -v /path/to/data:/data \
    -v /path/to/images:/images \
    -v /path/to/events:/events \
    --restart unless-stopped \
    -e 'UID=[your uid]' \
    -e 'GID=[your gid]' \
    -e 'TZ=Europe/Stockholm' \
    rundqvist/zoneminder
```

## Use
WebUI located at http://your-ip:8080/zm
Api located at http://your-ip:8080/zm/api
