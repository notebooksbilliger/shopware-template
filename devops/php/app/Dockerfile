# stage 1: create vendors folder
FROM composer:1.10 as vendor

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

# stage2: create application image and copy from stage1 vendors, so that caches will be reused
FROM php:7.4-apache-buster

ARG NEWRELIC_VERSION
ARG JWT_PRIVATE_KEY_PASSPHRASE

RUN export DOCKERIZE_VERSION=v0.6.1 \
&& apt-get update && apt-get install -y \
    autoconf \
    apt-utils \
    build-essential \
    unzip \
    libxml2-dev  \
    libzip-dev \
    libssl-dev \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libcurl4-openssl-dev \
    wget \
&& docker-php-ext-install -j$(nproc) \
    curl \
    bcmath \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    simplexml \
    xml \
    zip \
    intl \
&& docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
&& a2enmod headers \
    expires \
    rewrite \
    ssl \
# FE related things & helpers
&& curl -sL https://deb.nodesource.com/setup_13.x | bash - \
    && apt-get install -y build-essential nodejs \
    && node --version \
    && npm --version \
# add extensions for the FE build
&& npm install --save-dev webpack \
    sass \
# additional helper tools
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
&& wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
# install NewRelic
&& export NR_INSTALL_USE_CP_NOT_LN=1 \
    && export NR_INSTALL_SILENT=1 \
    && export NEWRELIC_ARCHIVE_URL="http://download.newrelic.com/php_agent/archive/${NEWRELIC_VERSION}/newrelic-php5-${NEWRELIC_VERSION}-linux.tar.gz" \
    && echo "Used URL to fetch NR agent and daemon: ${NEWRELIC_ARCHIVE_URL}" \
    && wget ${NEWRELIC_ARCHIVE_URL} \
    && tar xf newrelic-php5-${NEWRELIC_VERSION}-linux.tar.gz \
    && ./newrelic-php5-${NEWRELIC_VERSION}-linux/newrelic-install install \
    && rm -rf newrelic-php5-${NEWRELIC_VERSION}-linux* /etc/newrelic/newrelic.cfg \
#cleanup
&& apt-get autoclean -y \
    && apt-get purge -f -y autoconf \
        build-essential \
        libxml2-dev \
        libzip-dev \
        libssl-dev \
        wget \
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
        libcurl4-openssl-dev

COPY ./devops/php/app/configs/host.conf /etc/apache2/sites-available/000-default.conf
COPY ./devops/php/app/configs/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini
COPY ./devops/php/app/configs/php.ini /usr/local/etc/php/conf.d/z-php.ini
ADD  ./devops/php/app/usr/local/bin/ /usr/local/bin/

WORKDIR /app

# configs and code
COPY --chown=www-data:www-data ./ .
# vendors cache folder
COPY --chown=www-data:www-data --from=vendor /tmp/* /cache/composer/

EXPOSE 80

# and lets buid an application
RUN export COMPOSER_CACHE_DIR=/cache/composer \
    && apt-get install -y git \
    && shopware build:shopware-core \
    && composer clearcache
