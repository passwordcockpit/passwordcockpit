##############################################
# Build backend artifacts
##############################################

FROM php:7.3-apache as backend_artifacts
ARG PASSWORDCOCKPIT_BACKEND_TAG=1.2.0
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends git
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN set -ex; \
    apt-get update; \
    # zip
    apt-get install -y libzip-dev; \
    docker-php-ext-install zip; \
    # ldap
    apt-get install -y libldap2-dev; \
    docker-php-ext-install ldap; \
    # intl
    apt-get install -y --no-install-recommends libicu-dev; \
    docker-php-ext-install intl

WORKDIR /var/www/html

# clone the source of the backend
RUN set -ex; \
git clone -v git://github.com/passwordcockpit/backend.git /var/www/html; \
git checkout $PASSWORDCOCKPIT_BACKEND_TAG

# remove git history
RUN rm -rf .git

# clean application
RUN rm -rf docker
RUN rm -rf tests

# install and build
RUN composer install --prefer-dist --optimize-autoloader --no-dev

# generate swagger documentation
# create constants.local.php
RUN { \
	echo "<?php"; \
    echo "define('SWAGGER_API_HOST', 'PASSWORDCOCKPIT_BASEHOST');"; \
} > config/constants.local.php
RUN composer swagger

##############################################
# Build frontend artifacts
##############################################

FROM node:10-alpine as frontend_artifacts
ARG PASSWORDCOCKPIT_FRONTEND_TAG=1.1.1
RUN apk add git
WORKDIR /usr/src/app

# clone the source of the frontend
RUN set -ex; \
git clone -v git://github.com/passwordcockpit/frontend.git /usr/src/app; \
git checkout $PASSWORDCOCKPIT_FRONTEND_TAG

# create local.js
RUN { \
	echo "module.exports = {"; \
    echo "    baseHost: 'PASSWORDCOCKPIT_BASEHOST'"; \
    echo "};"; \
} > config/local.js

# install and build
RUN npm install -g ember-cli
RUN npm install
RUN ember build -p


##############################################
# Build the HTML and PHP container
##############################################

FROM php:7.3-apache
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
    apt-get update; \
    # ldap
    apt-get install -y --no-install-recommends libldap2-dev; \
    docker-php-ext-install ldap; \
    # intl
    apt-get install -y --no-install-recommends libicu-dev; \
    docker-php-ext-install intl; \
    # opcache
    docker-php-ext-install opcache; \
    # pdo_mysql
    docker-php-ext-install pdo_mysql; \
    # mod_rewrite extension
    a2enmod rewrite; \
    # ssl extension
    a2enmod ssl; \
    \
	# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*
    
# set recommended PHP.ini settings
# set production configuration
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini
    
WORKDIR /var/www/html
# set webroot
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# set DirectoryIndex priority to index.html
RUN sed -ri -e 's!DirectoryIndex index.php index.html!DirectoryIndex index.html index.php!g' /etc/apache2/conf-available/docker-php.conf

# copy frontend_artifacts 
COPY --from=backend_artifacts /var/www/html /var/www/html/
COPY --from=frontend_artifacts /usr/src/app/dist /var/www/html/public/

VOLUME /var/www/html/data

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

CMD ["apache2-foreground"]