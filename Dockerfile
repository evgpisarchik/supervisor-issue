FROM php:7.0.12-apache

ENV DEBIAN_FRONTEND=noninteractive

# Install the PHP extensions I need for my personnal project (gd, mbstring, opcache)
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev git mysql-client-5.5 wget \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache pdo zip

RUN apt-get update && apt-get install -y apt-utils adduser curl nano debconf-utils bzip2 dialog locales-all zlib1g-dev libicu-dev g++ gcc locales make build-essential supervisor

# Install imap extension
RUN apt-get install -y openssl
RUN apt-get install -y libc-client-dev
RUN apt-get install -y libkrb5-dev
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

# Install bz2
RUN apt-get install -y libbz2-dev
RUN docker-php-ext-install bz2

# Install mysql extension
RUN apt-get update && apt-get install -y --force-yes \
    freetds-dev \
 && rm -r /var/lib/apt/lists/* \
 && cp -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/ \
 && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
 && docker-php-ext-install \
    pdo_mysql \
    pdo_dblib \
    pdo_pgsql

# Install Tokenizer
RUN docker-php-ext-install tokenizer

RUN a2enmod rewrite
RUN a2enmod expires
RUN a2enmod mime
RUN a2enmod filter
RUN a2enmod deflate
RUN a2enmod proxy_http
RUN a2enmod headers
RUN a2enmod php7

RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin

# Edit PHP INI
RUN echo "memory_limit = 1G" > /usr/local/etc/php/php.ini
RUN echo "upload_max_filesize = 50M" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = 50M" >> /usr/local/etc/php/php.ini
RUN echo "max_input_time = 60" >> /usr/local/etc/php/php.ini
RUN echo "file_uploads = On" >> /usr/local/etc/php/php.ini
RUN echo "max_execution_time = 300" >> /usr/local/etc/php/php.ini
RUN echo "LimitRequestBody = 100000000" >> /usr/local/etc/php/php.ini

# Clean after install
RUN apt-get autoremove -y && apt-get clean all

# Configuration for Apache

RUN a2enmod rewrite

EXPOSE 80

# Change website folder rights and upload your website
RUN chown -R www-data:www-data /var/www/html
ADD ./ /var/www/html
RUN chmod +x /var/www/html/init.sh

# Change working directory
WORKDIR /var/www/html
ADD laravel-worker.conf /etc/supervisor/conf.d/
CMD ["/bin/bash","/var/www/html/init.sh"]