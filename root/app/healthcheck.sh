#!/bin/sh

if [ -z $(pgrep mysqld) ]; then
    echo "[ERROR  ] MariaDB process is not running" > /proc/1/fd/1
    exit 1;
fi

ZMSTATE=$(/usr/bin/zmdc.pl check)
if [ $ZMSTATE = "stopped" ]; then
    echo "[WARNING] Zoneminder is in state 'stopped'" > /proc/1/fd/1
    exit 1;
elif [ ! $ZMSTATE = "running" ]; then
    echo "[ERROR  ] Zoneminder state unknown" > /proc/1/fd/1
    exit 1;
fi

exit 0;