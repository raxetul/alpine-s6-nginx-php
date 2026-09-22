# alpine-s6-nginx-php
s6 supervised nginx with php, see https://github.com/raxetul/alpine-s6-base for more information.

Ships PHP 8.5 by default. Select another version with `--build-arg PHP_VERSION=84`
(e.g. 84 for PHP 8.4); PHP <= 8.4 additionally needs the matching
`php<VER>-opcache` package added to the image.
