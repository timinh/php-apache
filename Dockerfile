FROM php:8.1-apache

RUN a2enmod rewrite

RUN apt-get update \
    && apt-get install -y \
    git \
    nano \
    curl \
    cron \
    libzip-dev \
    libxml2-dev \
    zlib1g-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    libldb-dev \
    libldap2-dev \
    libldap-common \
    libonig-dev \
    libbz2-dev \
    libicu-dev \
    libxslt-dev \
    libssl-dev \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install \
    pdo \
    intl \
    mysqli \
    gd \
    ldap \
    gettext \
    calendar \
    ctype \
    session \
    dom \
    pdo \
    pdo_mysql \
    curl \
    zip;

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

WORKDIR /var/www/html

EXPOSE 80 443