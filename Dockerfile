FROM composer:1.8.0 AS composer
FROM php:7.2-apache 
COPY --from=composer:1.5 /usr/bin/composer /usr/bin/composer
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY timezone.ini $PHP_INI_DIR/conf.d/ 
COPY xdebug.ini $PHP_INI_DIR/conf.d/  
COPY php-add.ini $PHP_INI_DIR/conf.d/  
RUN mv /etc/localtime /etc/localtime.old \
 && ln -s /usr/share/zoneinfo/Europe/Warsaw /etc/localtime 
RUN a2enmod rewrite 
RUN a2enmod ssl
RUN apt-get update && apt-get install -y \
            vim \
            git \
            zlib1g-dev \
            libicu-dev \
            libgmp-dev \
            libfreetype6-dev \
            libjpeg62-turbo-dev \
            libpng-dev \
            libpq-dev \
            gnupg && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \ 
    && docker-php-ext-install zip intl gd gmp pgsql pdo_pgsql pdo_mysql exif pcntl opcache \
    && pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug 
RUN chmod -R 777 /usr/local/bin
#RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
# apt-get install -y nodejs

