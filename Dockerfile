FROM raxetul/alpine-s6-nginx

LABEL maintainer="Emrah URHAN <raxetul@gmail.com>"

## Single source of truth for the PHP version. It is the Alpine package
## suffix (no dot): 85 -> php85 / php-fpm85 / /etc/php85. Override at build
## time, e.g. `docker build --build-arg PHP_VERSION=84 .`, provided the
## matching php<VER>-* packages exist in the pinned Alpine release. For
## PHP <= 8.4 you must also add the matching php<VER>-opcache package back
## to the apk add list below, because only php85 has OPcache built in.
ARG PHP_VERSION=85
## Persist it to the image env so the s6 run script (with-contenv) can pick
## the right php-fpm<VER> binary at runtime.
ENV PHP_VERSION=${PHP_VERSION}

RUN apk add --no-cache \
    imagemagick-heic \
    imagemagick-jpeg \
    imagemagick-pdf \
    imagemagick-raw \
    imagemagick-svg \
    imagemagick-tiff \
    imagemagick-webp \
    php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-gettext \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-odbc \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-pcntl \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pdo_dblib \
    php${PHP_VERSION}-pdo_mysql \
    php${PHP_VERSION}-pdo_odbc \
    php${PHP_VERSION}-pdo_pgsql \
    php${PHP_VERSION}-pdo_sqlite \
    php${PHP_VERSION}-pecl-apcu \
    php${PHP_VERSION}-pecl-imagick \
    php${PHP_VERSION}-pecl-redis \
    php${PHP_VERSION}-posix \
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sodium \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-sysvsem \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlreader \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-zlib
## Note: php<VER>-json is intentionally omitted; JSON is compiled into PHP 8 core.
## Feedbacks for missing php modules are welcomed.

COPY s6-rc.d /etc/s6-overlay/s6-rc.d

RUN chmod +x /etc/s6-overlay/s6-rc.d/php-fpm/run \
    && echo "Fixing www.conf user and group settings, etc.. ----------" \
    && sed -i "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i "s/;listen.group = nobody/listen.group = nginx/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i "s/user = nobody/user = nginx/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = nginx/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php${PHP_VERSION}/php-fpm.conf \
    && sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i "s/;env/env/g" /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && echo "Enabling OPCache ----------" \
    && sed -i "s/;opcache.enable=1/opcache.enable=1/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/g" /etc/php${PHP_VERSION}/php.ini \
    && sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g" /etc/php${PHP_VERSION}/php.ini \
    && echo "apc.enabled=1" >>  /etc/php${PHP_VERSION}/conf.d/apcu.ini \
    && echo "apc.enable_cli=1" >>  /etc/php${PHP_VERSION}/conf.d/apcu.ini

## ENTRYPOINT (/init from s6-overlay) is inherited from alpine-s6-base. Do not override it.
