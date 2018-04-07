#!/bin/sh

#
# Optimize performance
#
if [ "$OPTIMIZE" = "once" ]; then

    if [ -f /data/optimized ]; then
        echo "[INFO   ] Zoneminder settings already optimized"
        OPTIMIZE="false"
    else
        OPTIMIZE="true"
    fi
fi

apk -q add --no-cache mariadb-client

CMD="mysqladmin ping -h localhost --silent --connect-timeout 1"
RES=$($CMD);

while [ ! "$RES" = "mysqld is alive" ]; do
    #echo "[INFO   ] Optimization waiting for mariadb"
    sleep 1
    RES=$($CMD);
done

if [ "$OPTIMIZE" = "true" ]; then

    mysql zm -e "UPDATE Config SET Value='0' WHERE Name='ZM_TIMESTAMP_ON_CAPTURE';"
    mysql zm -e "UPDATE Config SET Value='0' WHERE Name='ZM_CHECK_FOR_UPDATES';"
    mysql zm -e "UPDATE Config SET Value='1' WHERE Name='ZM_CPU_EXTENSIONS';"
    mysql zm -e "UPDATE Config SET Value='1' WHERE Name='ZM_FAST_IMAGE_BLENDS';"
    mysql zm -e "UPDATE Config SET Value='1' WHERE Name='ZM_OPT_ADAPTIVE_SKIP';"
    mysql zm -e "UPDATE Config SET Value='0' WHERE Name='ZM_CREATE_ANALYSIS_IMAGES';"
    mysql zm -e "UPDATE Config SET Value='0' WHERE Name='ZM_TELEMETRY_DATA';"
    mysql zm -e "UPDATE Config SET Value='/dev/shm' WHERE Name='ZM_PATH_MAP';"
    mysql zm -e "UPDATE Config SET Value='/dev/shm' WHERE Name='ZM_PATH_SWAP';"
    mysql zm -e "UPDATE Config SET Value='3600' WHERE Name='ZM_FILTER_RELOAD_DELAY';"
    mysql zm -e "UPDATE Config SET Value='3600' WHERE Name='ZM_FILTER_EXECUTE_INTERVAL';"
    mysql zm -e "UPDATE Config SET Value='-1' WHERE Name='ZM_LOG_LEVEL_FILE';"
    mysql zm -e "UPDATE Config SET Value='-1' WHERE Name='ZM_LOG_LEVEL_DATABASE';"

    echo "[INFO   ] Zoneminder settings optimized for best performance"
    touch /data/optimized
elif [ ! "$OPTIMIZE" = "false" ]; then
    echo "[WARNING] Zoneminder settings not optimized"
fi

apk -q del mariadb-client

echo "[INFO   ] Starting Zoneminder"
/usr/bin/zmpkg.pl start

rc=$? 

if [[ $rc != 0 ]]; then 
    echo "[ERROR  ] Zoneminder exited with exit status: "$rc
    exit $rc; 
fi

exit 0;