#!/bin/sh

#
# If no files in data directory, consider as first run and istall
#
if [ $(find /data -name mysql* | wc -l) -eq 0 ]; then

  echo "[INFO   ] First run, installing MariaDB"

  MYSQL_DATABASE='zm'
  MYSQL_USER='zmuser'
  MYSQL_PASSWORD='zmpass'
  
  mysql_install_db --user=root > /dev/null

  dbcreate=mktemp

  #
  # Create db.
  #
  echo "USE mysql;" > $dbcreate
  echo "FLUSH PRIVILEGES;" >> $dbcreate
  echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;" >> $dbcreate
  echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $dbcreate
  echo "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $dbcreate
  echo "GRANT CREATE, INSERT, SELECT, DELETE, UPDATE, DROP ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';" >> $dbcreate
  cat /usr/share/zoneminder/db/zm_create.sql >> $dbcreate

  /usr/bin/mysqld --user=root --bootstrap --verbose=0 < $dbcreate

  rm -f $dbcreate
  killall mysqld

else
  echo "[INFO   ] MariaDB already installed"
fi

#
# Setup timezone
#
LINKTZ=true

if [ -z "$TZ" ]; then
  echo "[INFO   ] No timezone in ENV, trying to resolve system timezone"

  checksum=`md5sum /etc/localtime | cut -d' ' -f1`
  TZ=`find /usr/share/zoneinfo/ -type f -exec md5sum {} \; | grep "^$checksum" | sed "s/.*\/usr\/share\/zoneinfo\///" | head -n 1`

  if [ -z "$TZ" ]; then
    echo "[WARNING] Could not resolve timezone, using Universal time"
    TZ="Universal"
  else
    LINKTZ=false
  fi

elif [ ! -f /usr/share/zoneinfo/$TZ ]; then
  echo "[WARNING] Timezone "$TZ" not valid, using Universal time"
  TZ="Universal"
fi

if $LINKTZ; then ln -sf /usr/share/zoneinfo/$TZ /etc/localtime; fi
sed -i 's|TIME_ZONE|'${TZ}'|g' /etc/php7/conf.d/50-setting.ini
echo "[INFO   ] Zoneminder configured for timezone: "$TZ

#
# Setup permissions
#
if [ -z "$GID" ]; then
  echo "[WARNING] No GID in ENV, possible permissions issue when saving events"
else

  if [ $(getent group $GID) ]; then
    echo "[INFO   ] Group with gid "$GID" exists"
  else
    echo "[INFO   ] Group with gid "$GID" does not exist, creating placeholder group"
    groupadd -g $GID primarygroup
  fi

  echo "[INFO   ] Setting primary group (gid) of user 'lighttpd' to "$GID
  usermod -g $GID lighttpd
fi

if [ -z "$UID" ]; then
  echo "[WARNING] No UID in ENV, possible permissions issue when saving events"
else
  echo "[INFO   ] Setting UID of user 'lighttpd' to "$UID
  usermod -u $UID lighttpd
fi

echo "[INFO   ] Updating permissions"
chown lighttpd:lighttpd \
    /etc/zm.conf \
    /var/log/zoneminder/ \
    /var/lib/zoneminder/temp \
    /usr/share/webapps/zoneminder/cgi-bin \
    /var/lib/zoneminder/templogs \
    /var/log/zonemindererror.log \
    /var/log/lighttpd
apk -q add --no-cache mariadb-client
#
# Start applications
#
echo "[INFO   ] Starting applications"
exec supervisord -c /etc/supervisord.conf
