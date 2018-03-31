FROM alpine:3.7

VOLUME [ "/data" ]
VOLUME [ "/images" ]
VOLUME [ "/events" ]

WORKDIR /app

RUN apk add --update --no-cache \
    php7 php7-fpm php7-pdo php7-pdo_mysql php7-session php7-sockets php7-ctype php7-cgi php7-soap php7-apcu php7-json \
    perl-data-uuid perl-data-dump perl-socket perl-io-socket-ssl perl-socket-getaddrinfo perl-protocol-websocket perl-xml-xpath

RUN apk add --no-cache --virtual .build-deps make gcc musl-dev perl-dev expat-dev php7-dev php7-pear \
    && cpan -f install Class::Std::Fast \
    && cpan -f install SOAP::WSDL \
    && cpan -f install IO::Socket::Multicast \
    && echo "n" | pecl install apcu_bc \
    && apk del .build-deps

RUN apk add --no-cache \
    shadow lighttpd supervisor mysql mysql-client zoneminder

RUN mkdir -p /home/buildozer/aports/community/zoneminder/src/ \
    && wget https://github.com/FriendsOfCake/crud/archive/c3976f1478c681b0bbc132ec3a3e82c3984eeed5.zip \
    && unzip c3976f1478c681b0bbc132ec3a3e82c3984eeed5.zip \
    && mv crud-c3976f1478c681b0bbc132ec3a3e82c3984eeed5 /home/buildozer/aports/community/zoneminder/src/ \
    && rm -f c3976f1478c681b0bbc132ec3a3e82c3984eeed5.zip

COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY 50-setting.ini /etc/php7/conf.d/50-setting.ini
COPY php-fpm.conf /etc/php7/php-fpm.d/www.conf
COPY my.cnf /etc/mysql/my.cnf
COPY mod_cgi.conf /etc/lighttpd/mod_cgi.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh entrypoint.sh

RUN mkdir -p /run/mysqld \
    && mkdir -p /var/lib/zoneminder/temp \
    && mkdir -p /var/www/localhost/htdocs/zm \
    && mkdir -p /var/lib/zoneminder/templogs \
    && touch /var/log/zonemindererror.log \
    && ln -s /images /var/www/localhost/htdocs/zm/images \
    && ln -s /events /var/www/localhost/htdocs/zm/events

RUN sed -i 's/\(ZM_WEB_\(USER\|GROUP\)\)=.*/\1=lighttpd/g' /etc/zm.conf

ENV TZ="Europe/Stockholm"
ENV UID=""
ENV GID=""

ENTRYPOINT [ "/app/entrypoint.sh" ]
