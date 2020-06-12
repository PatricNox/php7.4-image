FROM php:7.4-apache

LABEL maintainer="PatricNox <hello@patricnox.info>"

# Extract the PHP source.
RUN docker-php-source extract

# Install libs.
RUN apt-get update \
    && apt-get install -y \
        zip \
        unzip \
        git \
        curl \
        libmcrypt-dev \
        default-mysql-client \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev 

# Install PHP extensions.
RUN docker-php-ext-install \
    pdo_mysql \
    opcache \
    bcmath \
    zip

# Install GD.
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Copy the development PHP config from the PHP source.
RUN cp /usr/src/php/php.ini-development /usr/local/etc/php/php.ini

# Delete the PHP source.
RUN docker-php-source delete

# Install NodeJS with NPM
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install --yes nodejs

# Install composer
COPY --from=composer:1.7 /usr/bin/composer /usr/bin/composer

# Fix permissions for www-data.
RUN chown -R www-data:www-data /var/www
USER www-data

# Speed up composer downloads.
USER www-data
RUN /usr/bin/composer global require hirak/prestissimo
USER root
