# Zoneminder
All-in-one zoneminder image including zoneminder, web server, database and working api.
Working, but only for testing. Under development.

## Issues
* No timestamp on capture
* Access denied for user lighttpd to events/images on debian
* Pid files is created in mysql datadir for some reason

## Run from docker hub
docker run \
-d \
--shm-size=4096m \
--privileged \
-p 8080:80 \
--name zoneminder \
-v /path/to/data:/data \
-v /path/to/images:/images \
-v /path/to/events:/events \
rundqvist/zoneminder