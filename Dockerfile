## Set our base image ##
FROM php:8-apache

## Copy Default Config ##
COPY ./apache/000-default.conf /etc/apache2/sites-available/000-default.conf

## COPY Composer ##
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

## Install PHP Extension Installer ##
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

## Install Packages and Extensions and Cleanup ##
RUN apt-get update && apt-get install -y --no-install-recommends wget nano vim git && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install npm@latest -g && \
    install-php-extensions bcmath exif gd gettext imagick intl pdo_mysql zip mysqli && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* && \
    a2enmod rewrite

## Symlink for Node ##
RUN ln -s /usr/bin/node /usr/local/bin/node

## WordPress CLI ##
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

## User Permissions ##
ARG user_id=1000
ARG group_id=1000
RUN usermod -u $user_id www-data && groupmod -g $group_id www-data

## Healthcheck ##
#HEALTHCHECK CMD curl --fail http://localhost/healthcheck || exit 1

## Working Directory ##
WORKDIR /var/www/wordpress
