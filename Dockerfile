ARG VERSION=7.4
FROM php:${VERSION}-apache

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
	supervisor \
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
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions \
	opcache \
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
	amqp \
	mongodb \
	zip;

RUN docker-php-ext-configure exif \
	--enable-exif

RUN install-php-extensions @composer

# Gestion crons
COPY ./cron /etc/cron.d/cron
RUN chmod 0644 /etc/cron.d/cron
RUN crontab /etc/cron.d/cron

RUN sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground

WORKDIR /var/www/html

# RUN usermod -u 1000 www-data

RUN mkdir -p /var/www/html/public
RUN mkdir -p /var/www/html/var
RUN mkdir -p /var/www/html/var/cache
RUN mkdir -p /var/www/html/var/log
RUN chmod -R 777 /var/www/html/var

COPY ./vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./php.ini /usr/local/etc/php/conf.d/app.ini

EXPOSE 80 443

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Execute the entrypoint and start apache
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["apache2-foreground"]