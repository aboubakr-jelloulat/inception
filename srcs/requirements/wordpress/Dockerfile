FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    mariadb-client \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory
RUN mkdir -p /var/www/html

# IMPORTANT FIX: PHP-FPM runtime directory (your PID error fix)
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# PHP-FPM config
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Setup script
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]