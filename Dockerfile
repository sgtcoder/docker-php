## Set our base image ##
FROM php:8-cli

## Install Required Packages ##
RUN apt-get update && apt-get install -y --no-install-recommends wget nano vim git tar gnupg lsb-release automake libtool autoconf unzip procps jq

## Install gpg keys ##
RUN mkdir -p /root/.gnupg && chmod 700 /root/.gnupg
RUN mkdir -p /etc/apt/keyrings && install -m 0755 -d /etc/apt/keyrings
RUN gpg --no-default-keyring --keyring /etc/apt/keyrings/nodesource.gpg --recv-keys --keyserver keys.gnupg.net 1655A0AB68576280
RUN chown _apt /etc/apt/keyrings/*.gpg

## Setup Repos and apt pinning ##
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x $(lsb_release -sc) main" > /etc/apt/sources.list.d/nodesource.list

## Install PHP Extension Installer ##
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

## Install Packages and Extensions ##
RUN apt-get update && apt-get install -y --no-install-recommends nodejs
RUN install-php-extensions bcmath exif gd gettext imagick intl mysqli opcache pdo_mysql redis zip

## Symlink and update for Node ##
RUN ln -s /usr/bin/node /usr/local/bin/node
RUN npm install npm@latest -g

## COPY Composer ##
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

## Cleanup ##
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

## START CUSTOM ##

ENV PUID=1000
ENV PGID=1000

## WordPress CLI ##
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

## User Permissions ##
RUN mkdir /home/www-data
RUN usermod -u $PUID -d /home/www-data -s /bin/bash www-data && groupmod -g $PGID www-data

## Healthcheck ##
HEALTHCHECK CMD pgrep -f php || exit 1

## Cleanup ##
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*