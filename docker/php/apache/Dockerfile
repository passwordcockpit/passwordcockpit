##############################################
# Build backend artifacts
##############################################

FROM --platform=linux/amd64 php:8.5-apache-bookworm as backend_artifacts
ARG PASSWORDCOCKPIT_BACKEND_TAG=ce70618b76b6521a00458f0fed73bca148180974

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/* && \
    install-php-extensions \
    zip \
    ldap \
    intl \
    @composer

USER www-data:www-data

# clone the source of the backend
RUN set -ex; \
    git clone -v https://github.com/passwordcockpit/backend.git /var/www/html; \
    git checkout $PASSWORDCOCKPIT_BACKEND_TAG

# remove git history
RUN rm -rf .git

# clean application
RUN rm -rf docker
RUN rm -rf tests

# install and build
RUN composer install --prefer-dist --optimize-autoloader --no-dev

# configuration files
RUN set -ex; \
    mv config/autoload/client.local.php.dist config/autoload/client.local.php; \
    mv config/autoload/doctrine.local.php.dist config/autoload/doctrine.local.php; \
    mv config/autoload/crypt.local.php.dist config/autoload/crypt.local.php; \
    mv config/autoload/authentication.local.php.dist config/autoload/authentication.local.php; \
    mv config/autoload/ldap.local.php.dist config/autoload/ldap.local.php; \
    mv config/constants.local.php.dist config/constants.local.php

# generate swagger documentation
RUN { \
    echo "<?php"; \
    echo "define('SWAGGER_API_HOST', 'PASSWORDCOCKPIT_BASEHOST');"; \
    } > config/constants.local.php
RUN composer swagger

##############################################
# Build frontend artifacts
##############################################

FROM node:20.12 as frontend_artifacts
ARG PASSWORDCOCKPIT_FRONTEND_TAG=5e286e3dcca648ceaaf242cc8501ff24a8e20df6
RUN apt-get install git -y
WORKDIR /usr/src/app

# clone the source of the frontend
RUN set -ex; \
    git clone -v https://github.com/passwordcockpit/frontend.git /usr/src/app; \
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

FROM --platform=linux/amd64 php:8.5-apache-bookworm

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    a2enmod rewrite ssl headers && \
    install-php-extensions \
    ldap \
    intl \
    opcache \
    pdo_mysql

# PHP configurations    
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
# application configs
RUN set -ex; \
    \
    echo 'session.cookie_httponly = 1' >> /usr/local/etc/php/conf.d/application.ini; \
    echo 'session.cookie_secure = 1' >> /usr/local/etc/php/conf.d/application.ini; \
    echo 'expose_php = Off' >> /usr/local/etc/php/conf.d/application.ini

# apache configurations
# set webroot
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# set DirectoryIndex priority to index.html
RUN sed -ri -e 's!DirectoryIndex index.php index.html!DirectoryIndex index.html index.php!g' /etc/apache2/conf-available/docker-php.conf
# Set Security Headers (use https://csp-evaluator.withgoogle.com/)
RUN { \
    echo '<Directory ${APACHE_DOCUMENT_ROOT}>'; \
    echo 'Header set Strict-Transport-Security "max-age=10886400; includeSubDomains"'; \
    echo 'Header set Content-Security-Policy "default-src' "'self';base-uri 'self';font-src 'self' https: data:;form-action 'self';frame-ancestors 'self';img-src 'self' data:;object-src 'none';script-src 'self';script-src-attr 'none';style-src 'self' https: 'unsafe-inline';upgrade-insecure-requests"'"'; \
    echo '</Directory>'; \
    echo '<Directory ${APACHE_DOCUMENT_ROOT}/swagger>'; \
    echo 'Header unset Strict-Transport-Security'; \
    echo 'Header unset Content-Security-Policy'; \
    echo '</Directory>'; \
    } > /etc/apache2/conf-enabled/mod-rewrite.conf
# Hide Apache Version and Linux OS From HTTP Headers
RUN sed -ri -e 's!ServerTokens OS!ServerTokens Prod!g' /etc/apache2/conf-enabled/security.conf
RUN sed -ri -e 's!ServerSignature On!ServerSignature Off!g' /etc/apache2/conf-enabled/security.conf
# SSL
RUN set -ex; \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=CH/ST=ZH/L=Zurich/O=Passwordcockpit" -keyout /etc/ssl/certs/passwordcockpit.key -out /etc/ssl/certs/passwordcockpit.crt; \
    chmod 644 /etc/ssl/certs/passwordcockpit.key; \
    sed -ri -e 's!ssl-cert-snakeoil.pem!'passwordcockpit.crt'!g' /etc/apache2/sites-available/default-ssl.conf; \
    sed -ri -e 's!/etc/ssl/private/ssl-cert-snakeoil.key!'/etc/ssl/certs/passwordcockpit.key'!g' /etc/apache2/sites-available/default-ssl.conf; \
    mv /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
# adjust the Apache configuration to use an unprivileged port
RUN set -ex; \
    sed -i "s/80/8080/g" /etc/apache2/sites-enabled/000-default.conf; \
    sed -i "s/80/8080/g" /etc/apache2/ports.conf
EXPOSE 8080
RUN set -ex; \
    sed -i "s/443/4343/g" /etc/apache2/sites-enabled/default-ssl.conf; \
    sed -i "s/443/4343/g" /etc/apache2/ports.conf
EXPOSE 4343
# Operation not supported: AH00023: Couldn't create the mpm-accept mutex passwordcockpit | (95)Operation not supported: could not create accept mutex on Apple m1
RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

# copy frontend_artifacts 
COPY --from=backend_artifacts /var/www/html /var/www/html/
RUN chown root:root -R /var/www/html
COPY --from=frontend_artifacts /usr/src/app/dist /var/www/html/public/

WORKDIR /var/www/html
VOLUME /var/www/html/data

# Change permission
RUN set -ex; \
    chmod -R 777 /var/www/html/data; \ 
    chmod -R 777 /var/www/html/upload; \
    chmod 777 /var/www/html/tmp; \
    chmod 777 /var/www/html/public; \
    chmod 777 /var/www/html/public/index.html; \
    chmod -R 777 /var/www/html/public/assets; \
    chmod -R 777 /var/www/html/swagger

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

USER www-data:www-data

CMD ["apache2-foreground"]