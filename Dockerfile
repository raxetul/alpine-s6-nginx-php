FROM raxetul/alpine-s6-nginx

LABEL maintainer="Emrah URHAN <raxetul@gmail.com>"

RUN apk update && apk add --no-cache \
    php8 \
    php8-bcmath \
    php8-bz2 \
    php8-curl \
    php8-ctype \
    php8-dom \
    php8-fileinfo \
    php8-fpm \
    php8-gd \
    php8-gettext \
    php8-gmp \
    php8-iconv \
    php8-intl \
    php8-json \
    php8-mbstring \
    php8-mysqli \
    php8-odbc \
    php8-opcache \
    php8-openssl \
    php8-pcntl \
    php8-pdo \
    php8-pdo_dblib \
    php8-pdo_mysql \
    php8-pdo_odbc \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-pecl-apcu \
    php8-pecl-imagick \
    php8-pecl-mcrypt \
    php8-posix \
    php8-session \
    php8-simplexml \
    php8-soap \
    php8-sqlite3 \
    php8-xmlreader \
    php8-xmlwriter \
    php8-zip \
    php8-zlib \
    && rm -rf /var/cache/apk/*
## Feedbacks for missing php modules are welcomed.

ADD php-fpm /s6/php-fpm

RUN chmod +x /s6/php-fpm/run /s6/php-fpm/finish \
    && chown root /s6/php-fpm/run /s6/php-fpm/finish \
    && mkdir -p /run/nginx && touch /run/nginx/nginx.pid \
    && echo "Fixing www.conf user and group settings, etc.. ----------" \
    && sed -i "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php8/php-fpm.d/www.conf \
    && sed -i "s/;listen.group = nobody/listen.group = nginx/g" /etc/php8/php-fpm.d/www.conf \
    && sed -i "s/user = nobody/user = nginx/g" /etc/php8/php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = nginx/g" /etc/php8/php-fpm.d/www.conf \
    && sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php8/php-fpm.conf \
    && sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php8/php-fpm.d/www.conf \
    && sed -i "s/;env/env/g" /etc/php8/php-fpm.d/www.conf \
    && echo "Enabling OPCache ----------" \
    && sed -i "s/;opcache.enable=1/opcache.enable=1/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/g" /etc/php8/php.ini \
    && sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g" /etc/php8/php.ini \
    && echo "apc.enabled=1" >>  /etc/php8/conf.d/apcu.ini \
    && echo "apc.enable_cli=1" >>  /etc/php8/conf.d/apcu.ini

VOLUME /etc/php8/php.ini

## Don't setup ENTRYPOINT, it is set to s6 superviser in alpine-s6-base image, see Dockerfile of alpine-s6-base image
