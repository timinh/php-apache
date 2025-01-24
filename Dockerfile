ARG VERSION=8.0
FROM php:${VERSION}-apache

ARG ARG_TIMEZONE=Europe/Paris
ENV ENV_TIMEZONE=${ARG_TIMEZONE}

RUN echo "$ENV_TIMEZONE" > /etc/timezone \
	&& ln -fsn /usr/share/zoneinfo/"$ENV_TIMEZONE" /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN a2enmod rewrite

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

RUN curl -fsSL \
		-o /usr/local/bin/install-php-extensions \
	https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && chmod +x /usr/local/bin/install-php-extensions

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
	soap \
	zip;

RUN docker-php-ext-configure exif \
	&& docker-php-ext-configure soap --enable-soap

RUN install-php-extensions @composer

# Gestion crons
# Installation supercronic
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=71b0d58cc53f6bd72cf2f293e09e294b79c666d8 \
    SUPERCRONIC=supercronic-linux-amd64

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

RUN touch /tmp/supervisord.sock && chmod 777 /tmp/supervisord.sock
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./crontab /etc/crontabs/crontab


# RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
RUN mkdir -p /var/www/html/public

COPY ./vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./php.ini /usr/local/etc/php/conf.d/app.ini

RUN mkdir -p /var/www/html/var/log \
	&& chown -R www-data:www-data /var/www/html/var/log

EXPOSE 80 443

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV COMPOSER_ALLOW_SUPERUSER=1

CMD ["apache2-foreground"]

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]