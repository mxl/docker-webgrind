FROM php:5-fpm-alpine

MAINTAINER Michael Ledin <mledin89@gmail.com>

ENV TIMEZONE             Europe/Moscow
ENV PHP_MEMORY_LIMIT     64M
ENV WEBGRIND_STORAGE_DIR /var/webgrind
ENV XDEBUG_OUTPUT_DIR    /tmp
ENV PHP_INI_PATH /usr/local/etc/php/php.ini
ENV WEB_ROOT /var/www/html

RUN apk update && apk add --no-cache git\
    # Python and Graphviz for function call graphs
    python graphviz\
    # for making binary preprocessor
    g++ make musl-dev &&\
    cd .. &&\
    rm -rf $WEB_ROOT &&\
    git clone --depth=1 --branch=master https://github.com/jokkedk/webgrind $WEB_ROOT &&\
    cd $WEB_ROOT &&\
    chown www-data:www-data -R . &&\
    rm -rf .git &&\
    apk del git

RUN \
    # configure php
    mv $PHP_INI_PATH-production $PHP_INI_PATH &&\
    sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" $PHP_INI_PATH &&\
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" $PHP_INI_PATH &&\
    # configure webgrind
    sed -i "s|.*storageDir =.*|static \$storageDir = '${WEBGRIND_STORAGE_DIR}';|i" ${WEB_ROOT}/config.php &&\
    sed -i "s|.*profilerDir =.*|static \$profilerDir = '${XDEBUG_OUTPUT_DIR}';|i" ${WEB_ROOT}/config.php

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

RUN mkdir -p $WEBGRIND_STORAGE_DIR

RUN make

VOLUME ${XDEBUG_OUTPUT_DIR}
