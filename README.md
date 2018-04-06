# Docker Zoneminder
All-in-one Zoneminder image built on Alpine Linux and Php7 aiming for a compact container with low resource usage.

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
| TZ | Your time zone (in format: 'Europe/Stockholm'). Use this if mounting /etc/localtime don't work. |
| OPTIMIZE | 'once' optimizes Zoneminder for best performance one time. 'true' resets to optimized settings on every start. 'false' do not optimize settings. |

Not mandatory to run in privileged mode, but it seems to make Zoneminder more stable aswell as giving a performance boost.

## Run
```
$ docker run \
    -d \
    -p 8080:80 \
    -v /path/to/data:/data \
    -v /path/to/images:/images \
    -v /path/to/events:/events \
    -e 'UID=[your uid]' \
    -e 'GID=[your gid]' \
    -e "OPTIMIZE=true" \
    -v /etc/localtime:/etc/localtime:ro \
    --privileged \
    --shm-size=4096m \
    --restart unless-stopped \
    --name zoneminder \
    rundqvist/zoneminder
```

## Use
WebUI located at http://your-ip:8080/zm
Api located at http://your-ip:8080/zm/api

## Issues
Please report issues at https://github.com/rundqvist/docker-zoneminder/issues
