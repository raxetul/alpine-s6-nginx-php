FROM raxetul/alpine-s6-nginx

LABEL maintainer="Emrah URHAN <raxetul@gmail.com>"

RUN apk add --no-cache \
    imagemagick-heic \
    imagemagick-jpeg \
    imagemagick-pdf \
    imagemagick-raw \
    imagemagick-svg \
    imagemagick-tiff \
    imagemagick-webp \
    php84 \
    php84-bcmath \
    php84-bz2 \
    php84-curl \
    php84-ctype \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-fpm \
    php84-gd \
    php84-gettext \
    php84-gmp \
    php84-iconv \
    php84-intl \
    php84-mbstring \
    php84-mysqli \
    php84-odbc \
    php84-opcache \
    php84-openssl \
    php84-pcntl \
    php84-pdo \
    php84-pdo_dblib \
    php84-pdo_mysql \
    php84-pdo_odbc \
    php84-pdo_pgsql \
    php84-pdo_sqlite \
    php84-pecl-apcu \
    php84-pecl-imagick \
    php84-pecl-redis \
    php84-posix \
    php84-session \
    php84-simplexml \
    php84-soap \
    php84-sodium \
    php84-sqlite3 \
    php84-sysvsem \
    php84-xml \
    php84-xmlreader \
    php84-xmlwriter \
    php84-zip \
    php84-zlib
## Note: php84-json no longer exists; JSON is compiled into PHP 8 core.
## Feedbacks for missing php modules are welcomed.

COPY s6-rc.d /etc/s6-overlay/s6-rc.d

RUN chmod +x /etc/s6-overlay/s6-rc.d/php-fpm/run \
    && echo "Fixing www.conf user and group settings, etc.. ----------" \
    && sed -i "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php84/php-fpm.d/www.conf \
    && sed -i "s/;listen.group = nobody/listen.group = nginx/g" /etc/php84/php-fpm.d/www.conf \
    && sed -i "s/user = nobody/user = nginx/g" /etc/php84/php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = nginx/g" /etc/php84/php-fpm.d/www.conf \
    && sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php84/php-fpm.conf \
    && sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php84/php-fpm.d/www.conf \
    && sed -i "s/;env/env/g" /etc/php84/php-fpm.d/www.conf \
    && echo "Enabling OPCache ----------" \
    && sed -i "s/;opcache.enable=1/opcache.enable=1/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/g" /etc/php84/php.ini \
    && sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g" /etc/php84/php.ini \
    && echo "apc.enabled=1" >>  /etc/php84/conf.d/apcu.ini \
    && echo "apc.enable_cli=1" >>  /etc/php84/conf.d/apcu.ini

## ENTRYPOINT (/init from s6-overlay) is inherited from alpine-s6-base. Do not override it.
