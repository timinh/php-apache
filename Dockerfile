FROM php:8.1-apache

RUN a2enmod rewrite \
    a2enmod http2

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

RUN sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground

WORKDIR /var/www/html

RUN usermod -u 1000 www-data

EXPOSE 80 443
