FROM php:8.1-apache

ARG ARG_TIMEZONE=Europe/Paris
ENV ENV_TIMEZONE ${ARG_TIMEZONE}

RUN echo '$ENV_TIMEZONE' > /etc/timezone \
    && ln -fsn /usr/share/zoneinfo/$ENV_TIMEZONE /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN a2enmod rewrite http2

RUN apt-get update \
	&& apt-get install -y \
	git \
	nano \
	vim \
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
	librabbitmq-dev \
	--no-install-recommends \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& pecl install amqp

RUN docker-php-ext-install \
	opcache \
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
	exif \
	bcmath \
	zip;

RUN docker-php-ext-enable amqp
RUN docker-php-ext-configure exif \
	--enable-exif

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

RUN sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground

WORKDIR /var/www/html

RUN usermod -u 1000 www-data

EXPOSE 80 443
