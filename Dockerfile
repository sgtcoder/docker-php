## Set our base image ##
FROM sgtcoder/apache-base

## WordPress CLI ##
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

## Copy Default Config ##
COPY ./configs/000-default.conf /etc/apache2/sites-available/000-default.conf

## User Permissions ##
ARG user_id=1000
ARG group_id=1000
RUN usermod -u $user_id www-data && groupmod -g $group_id www-data

## Healthcheck ##
#HEALTHCHECK CMD curl --fail http://localhost/healthcheck || exit 1

## Cleanup ##
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

## Working Directory ##
WORKDIR /var/www/wordpress
