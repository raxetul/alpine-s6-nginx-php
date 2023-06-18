FROM raxetul/alpine-s6-nginx

LABEL maintainer="Emrah URHAN <raxetul@gmail.com>"

RUN apk update && apk add --no-cache \
    php82 \
    php82-bcmath \
    php82-bz2 \
    php82-curl \
    php82-ctype \
    php82-dom \
    php82-fileinfo \
    php82-fpm \
    php82-gd \
    php82-gettext \
    php82-gmp \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-mbstring \
    php82-mysqli \
    php82-odbc \
    php82-opcache \
    php82-openssl \
    php82-pcntl \
    php82-pdo \
    php82-pdo_dblib \
    php82-pdo_mysql \
    php82-pdo_odbc \
    php82-pdo_pgsql \
    php82-pdo_sqlite \
    php82-pecl-apcu \
    php82-pecl-imagick \
    php82-posix \
    php82-session \
    php82-simplexml \
    php82-soap \
    php82-sqlite3 \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-zip \
    php82-zlib \
    && rm -rf /var/cache/apk/*
## Feedbacks for missing php modules are welcomed.

ADD php-fpm /s6/php-fpm

RUN chmod +x /s6/php-fpm/run /s6/php-fpm/finish \
    && chown root /s6/php-fpm/run /s6/php-fpm/finish \
    && mkdir -p /run/nginx && touch /run/nginx/nginx.pid \
    && echo "Fixing www.conf user and group settings, etc.. ----------" \
    && sed -i "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php82/php-fpm.d/www.conf \
    && sed -i "s/;listen.group = nobody/listen.group = nginx/g" /etc/php82/php-fpm.d/www.conf \
    && sed -i "s/user = nobody/user = nginx/g" /etc/php82/php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = nginx/g" /etc/php82/php-fpm.d/www.conf \
    && sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php82/php-fpm.conf \
    && sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php82/php-fpm.d/www.conf \
    && sed -i "s/;env/env/g" /etc/php82/php-fpm.d/www.conf \
    && echo "Enabling OPCache ----------" \
    && sed -i "s/;opcache.enable=1/opcache.enable=1/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/g" /etc/php82/php.ini \
    && sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g" /etc/php82/php.ini \
    && echo "apc.enabled=1" >>  /etc/php82/conf.d/apcu.ini \
    && echo "apc.enable_cli=1" >>  /etc/php82/conf.d/apcu.ini

## Don't setup ENTRYPOINT, it is set to s6 superviser in alpine-s6-base image, see Dockerfile of alpine-s6-base image
