## Set our base image ##
FROM sgtcoder/apache-base

ENV PUID=1000
ENV PGID=1000
ENV DOCUMENT_ROOT="/var/www/html"

## WordPress CLI ##
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

## Copy Default Config ##
COPY ./configs/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./configs/healthcheck.conf /etc/apache2/conf-enabled/healthcheck.conf

## User Permissions ##
RUN usermod -u $PUID www-data && groupmod -g $PGID www-data

## Healthcheck ##
HEALTHCHECK CMD curl --fail http://localhost:5000/healthcheck || exit 1

## Cleanup ##
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

## Working Directory ##
WORKDIR $DOCUMENT_ROOT
